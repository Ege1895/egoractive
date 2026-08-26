import { Environment, NotificationTypeV2, Subtype, SignedDataVerifier } from "@apple/app-store-server-library";
import { getFirestore } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { markSubscriptionCancelAtPeriodEnd, applySubscriptionUpdate } from "../shared/apply-subscription-update";
import { gymDoc } from "../shared/firestore-paths";
import { IOS_BUNDLE_ID, isKnownSubscriptionProductId } from "../shared/subscription-constants";
import { resolveGymIdForTransaction } from "../shared/subscription-transactions";
import { verifyAppleReceipt } from "../shared/subscription-verification";

const appleSharedSecret = defineSecret("APPLE_SUBSCRIPTION_SHARED_SECRET");
/**
 * Apple PKI sitesinden (https://www.apple.com/certificateauthority/) indirilen
 * DER kök sertifikaların her biri base64'e çevrilip virgülle birleştirilmiş
 * hali — bkz. `docs/Abonelik_Store_Kurulumu.md`.
 */
const appleRootCertificatesBase64 = defineSecret("APPLE_ROOT_CA_CERTIFICATES_BASE64");

/** Entitlement'ı gerçekten değiştirebilecek, tepki vermeye değer bildirim tipleri. */
const ACTIONABLE_TYPES = new Set<string>([
  NotificationTypeV2.DID_RENEW,
  NotificationTypeV2.EXPIRED,
  NotificationTypeV2.DID_FAIL_TO_RENEW,
  NotificationTypeV2.GRACE_PERIOD_EXPIRED,
  NotificationTypeV2.REFUND,
  NotificationTypeV2.REVOKE,
]);

/**
 * Salon Abonelik ve Erişim Akışı (Bölüm 16) — App Store Server Notifications
 * V2 alıcısı. Apple'ın imzaladığı `signedPayload`'ı doğrular, işlem bilgisini
 * (`signedTransactionInfo`) çözüp `originalTransactionId`'den salonu bulur,
 * ve Apple'ı KENDİ verify-receipt uç noktasından tekrar sorgulayarak
 * (`verifyAppleReceipt` — bildirimin kendi alanlarına güvenmek yerine, Bölüm
 * 13: store entitlement source-of-truth) günceller.
 *
 * NOT: Bu fonksiyon App Store Connect'te bir "Production Server URL"
 * girilmeden hiç tetiklenmez — store kurulumu tamamlanana kadar kod hazır
 * ama devrede değildir (bkz. docs/Abonelik_Store_Kurulumu.md).
 */
export const appleServerNotifications = onRequest(
  { secrets: [appleSharedSecret, appleRootCertificatesBase64] },
  async (req, res) => {
    const signedPayload = req.body?.signedPayload;
    if (typeof signedPayload !== "string") {
      res.status(400).send("Missing signedPayload");
      return;
    }

    try {
      const rootCertificates = appleRootCertificatesBase64
        .value()
        .split(",")
        .map((b64) => Buffer.from(b64.trim(), "base64"));
      const verifier = new SignedDataVerifier(rootCertificates, true, Environment.PRODUCTION, IOS_BUNDLE_ID);

      const notification = await verifier.verifyAndDecodeNotification(signedPayload);
      const notificationType = notification.notificationType;
      const subtype = notification.subtype;
      const signedTransactionInfo = notification.data?.signedTransactionInfo;

      if (!notificationType || !signedTransactionInfo) {
        logger.info("appleServerNotifications: işlenecek transaction bilgisi yok, yok sayıldı.", { notificationType });
        res.status(200).send("ignored");
        return;
      }

      const transaction = await verifier.verifyAndDecodeTransaction(signedTransactionInfo);
      const originalTransactionId = transaction.originalTransactionId;
      const productId = transaction.productId;
      if (!originalTransactionId || !productId || !isKnownSubscriptionProductId(productId)) {
        res.status(200).send("ignored");
        return;
      }

      const gymId = await resolveGymIdForTransaction(originalTransactionId);
      if (!gymId) {
        logger.warn(`appleServerNotifications: ${originalTransactionId} için salon bulunamadı.`);
        res.status(200).send("ignored");
        return;
      }

      // Kullanıcı store'dan iptal ettiğinde (ama entitlement expiry'e kadar
      // geçerliyken) tam yeniden doğrulamaya gerek yok — sadece bayrağı
      // güncelle (Bölüm 12). Gerçek erişim kaybı, expiry gerçekten geçince
      // subscriptionRenewalCheck/EXPIRED bildirimi ile olur.
      if (notificationType === NotificationTypeV2.DID_CHANGE_RENEWAL_STATUS) {
        if (subtype === Subtype.AUTO_RENEW_DISABLED) {
          await markSubscriptionCancelAtPeriodEnd(gymId);
        } else if (subtype === Subtype.AUTO_RENEW_ENABLED) {
          await getFirestore().doc(gymDoc(gymId)).set({ subscriptionCancelAtPeriodEnd: false }, { merge: true });
        }
        res.status(200).send("ok");
        return;
      }

      if (!ACTIONABLE_TYPES.has(notificationType)) {
        res.status(200).send("ignored");
        return;
      }

      const gymSnap = await getFirestore().doc(gymDoc(gymId)).get();
      const rawVerificationData = gymSnap.data()?.subscriptionLastVerificationData as string | undefined;
      if (!rawVerificationData) {
        logger.warn(`appleServerNotifications: ${gymId} için saklı makbuz yok, doğrulanamadı.`);
        res.status(200).send("ignored");
        return;
      }

      const verified = await verifyAppleReceipt({
        receiptData: rawVerificationData,
        productId,
        sharedSecret: appleSharedSecret.value(),
      });
      await applySubscriptionUpdate({
        gymId,
        verified,
        productId,
        platform: "ios",
        source: "webhook",
        rawVerificationData,
      });

      res.status(200).send("ok");
    } catch (error) {
      logger.error("appleServerNotifications: işlenemedi.", error);
      res.status(500).send("error");
    }
  },
);
