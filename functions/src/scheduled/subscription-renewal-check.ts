import { Timestamp, getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";

import { applySubscriptionUpdate } from "../shared/apply-subscription-update";
import { withFailureAlerting } from "../shared/function-health";
import { verifyAppleTransaction, verifyGooglePurchase } from "../shared/subscription-verification";

const appleRootCertificatesBase64 = defineSecret("APPLE_ROOT_CA_CERTIFICATES_BASE64");
const googlePlayServiceAccountJson = defineSecret("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON");

const LOOKAHEAD_MS = 24 * 60 * 60 * 1000;

/**
 * Salon Abonelik ve Erişim Akışı (Bölüm 5/6) — 14 günlük deneme ya da bir
 * yenileme döneminin SONUNDA store'un gerçekten ücreti çekip çekmediğini
 * (ya da yenileyip yenilemediğini) tespit eder. Bu, `apple-server-notifications`/
 * `google-play-rtdn` webhook'larının bir yedeği — webhook konfigürasyonu
 * (ASC bildirim URL'i, Play RTDN Pub/Sub) henüz store console'da kurulmadı
 * ve kurulsa bile ağ/gecikme sorunlarıyla bir bildirim kaçabilir. Bu job
 * `subscriptionExpiresAt`'i geçmiş/24 saat içinde olan her `trial`/`active`
 * salonun SON bilinen makbuz/token'ını (`subscriptionLastVerificationData`)
 * tekrar Apple/Google'a sorar — aynen `trialExpiryCheck`'in (saf Firestore
 * sayacı) yaptığı gibi günde bir kez çalışır, ama gerçek store entitlement'ını
 * kaynak olarak kullanır (Bölüm 13: sistem kendi başına "birkaç gün daha
 * kullanabilir" kararı vermemeli — store ne diyorsa o).
 */
export const subscriptionRenewalCheck = onSchedule(
  { schedule: "every 24 hours", secrets: [appleRootCertificatesBase64, googlePlayServiceAccountJson] },
  withFailureAlerting("subscriptionRenewalCheck", async () => {
    const db = getFirestore();
    const cutoff = Timestamp.fromMillis(Date.now() + LOOKAHEAD_MS);

    const snapshot = await db
      .collection("gyms")
      .where("subscriptionStatus", "in", ["trial", "active"])
      .where("subscriptionExpiresAt", "<=", cutoff)
      .get();

    if (snapshot.empty) return;

    let checked = 0;
    let updated = 0;
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const rawVerificationData = data.subscriptionLastVerificationData as string | undefined;
      const platform = data.subscriptionLastVerificationPlatform as "ios" | "android" | undefined;
      const productId = data.subscriptionProductId as string | undefined;
      if (!rawVerificationData || !platform || !productId) continue;

      checked++;
      try {
        const verified =
          platform === "ios"
            ? await verifyAppleTransaction({
                signedTransactionInfo: rawVerificationData,
                productId,
                rootCertificatesBase64: appleRootCertificatesBase64.value(),
              })
            : await verifyGooglePurchase({
                purchaseToken: rawVerificationData,
                productId,
                serviceAccountJson: googlePlayServiceAccountJson.value(),
              });

        const newStatus = await applySubscriptionUpdate({
          gymId: doc.id,
          verified,
          productId,
          platform,
          source: "reverify",
          rawVerificationData,
        });
        if (newStatus !== data.subscriptionStatus) updated++;
      } catch (error) {
        logger.error(`subscriptionRenewalCheck: ${doc.id} için yeniden doğrulama başarısız oldu.`, error);
      }
    }

    logger.info(`subscriptionRenewalCheck: ${checked} salon kontrol edildi, ${updated} tanesinin durumu değişti.`);
  }),
);
