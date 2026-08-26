import { getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { onMessagePublished } from "firebase-functions/v2/pubsub";
import * as logger from "firebase-functions/logger";

import { markSubscriptionCancelAtPeriodEnd, applySubscriptionUpdate } from "../shared/apply-subscription-update";
import { gymDoc } from "../shared/firestore-paths";
import { isKnownSubscriptionProductId } from "../shared/subscription-constants";
import { resolveGymIdForTransaction } from "../shared/subscription-transactions";
import { verifyGooglePurchase } from "../shared/subscription-verification";

const googlePlayServiceAccountJson = defineSecret("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON");

/**
 * Play Console'da "Monetization setup" altında bu isimle bir Pub/Sub topic
 * oluşturup Real-time developer notifications'a bağlaman gerekiyor — bkz.
 * docs/Abonelik_Store_Kurulumu.md. Bu fonksiyon o topic'e abone olur.
 */
const RTDN_TOPIC = "play-subscriptions";

/** Google Play RTDN `notificationType` sayısal kodları (SubscriptionNotificationType). */
const NOTIFICATION_TYPE = {
  SUBSCRIPTION_RECOVERED: 1,
  SUBSCRIPTION_RENEWED: 2,
  SUBSCRIPTION_CANCELED: 3,
  SUBSCRIPTION_ON_HOLD: 5,
  SUBSCRIPTION_RESTARTED: 7,
  SUBSCRIPTION_PAUSED: 10,
  SUBSCRIPTION_REVOKED: 12,
  SUBSCRIPTION_EXPIRED: 13,
} as const;

const REVERIFY_TYPES = new Set<number>([
  NOTIFICATION_TYPE.SUBSCRIPTION_RECOVERED,
  NOTIFICATION_TYPE.SUBSCRIPTION_RENEWED,
  NOTIFICATION_TYPE.SUBSCRIPTION_RESTARTED,
  NOTIFICATION_TYPE.SUBSCRIPTION_ON_HOLD,
  NOTIFICATION_TYPE.SUBSCRIPTION_PAUSED,
  NOTIFICATION_TYPE.SUBSCRIPTION_REVOKED,
  NOTIFICATION_TYPE.SUBSCRIPTION_EXPIRED,
]);

interface DeveloperNotification {
  packageName?: string;
  subscriptionNotification?: {
    notificationType?: number;
    purchaseToken?: string;
    subscriptionId?: string;
  };
  testNotification?: { version?: string };
}

/**
 * Salon Abonelik ve Erişim Akışı (Bölüm 16) — Google Play Real-time
 * Developer Notifications alıcısı. Play Console'un Pub/Sub topic'ine
 * yayınlanan `DeveloperNotification`'ı çözer, `purchaseToken`'dan salonu
 * bulur, Play Developer API'yi (`verifyGooglePurchase`) tekrar sorgulayarak
 * (Bölüm 13: store entitlement source-of-truth) günceller.
 *
 * NOT: Play Console'da bu topic'e RTDN bağlanmadan hiç tetiklenmez — store
 * kurulumu tamamlanana kadar kod hazır ama devrede değildir.
 */
export const googlePlayRtdn = onMessagePublished(
  { topic: RTDN_TOPIC, secrets: [googlePlayServiceAccountJson] },
  async (event) => {
    let notification: DeveloperNotification;
    try {
      notification = event.data.message.json as DeveloperNotification;
    } catch (error) {
      logger.error("googlePlayRtdn: mesaj JSON olarak çözülemedi.", error);
      return;
    }

    if (notification.testNotification) {
      logger.info("googlePlayRtdn: test bildirimi alındı.");
      return;
    }

    const sub = notification.subscriptionNotification;
    const notificationType = sub?.notificationType;
    const purchaseToken = sub?.purchaseToken;
    const productId = sub?.subscriptionId;
    if (!notificationType || !purchaseToken || !productId || !isKnownSubscriptionProductId(productId)) {
      return;
    }

    const gymId = await resolveGymIdForTransaction(purchaseToken);
    if (!gymId) {
      logger.warn(`googlePlayRtdn: ${purchaseToken} için salon bulunamadı.`);
      return;
    }

    // Bölüm 12 — kullanıcı Play'den iptal ettiğinde (auto-renew kapandı) ama
    // entitlement expiry'e kadar geçerliyken sadece bayrağı güncelle.
    if (notificationType === NOTIFICATION_TYPE.SUBSCRIPTION_CANCELED) {
      await markSubscriptionCancelAtPeriodEnd(gymId);
      return;
    }

    if (!REVERIFY_TYPES.has(notificationType)) return;

    try {
      const gymSnap = await getFirestore().doc(gymDoc(gymId)).get();
      const rawVerificationData = gymSnap.data()?.subscriptionLastVerificationData as string | undefined;
      const verificationToken = rawVerificationData ?? purchaseToken;

      const verified = await verifyGooglePurchase({
        purchaseToken: verificationToken,
        productId,
        serviceAccountJson: googlePlayServiceAccountJson.value(),
      });
      await applySubscriptionUpdate({
        gymId,
        verified,
        productId,
        platform: "android",
        source: "webhook",
        rawVerificationData: verificationToken,
      });
    } catch (error) {
      logger.error(`googlePlayRtdn: ${gymId} için yeniden doğrulama başarısız oldu.`, error);
    }
  },
);
