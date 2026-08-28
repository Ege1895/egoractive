import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

import { applySubscriptionUpdate } from "../shared/apply-subscription-update";
import { isKnownSubscriptionProductId } from "../shared/subscription-constants";
import { verifyAppleTransaction, verifyGooglePurchase } from "../shared/subscription-verification";

/**
 * Apple PKI sitesinden indirilen kök sertifikalar, base64 + virgülle
 * birleştirilmiş — `verifyAppleTransaction`'ın JWS imza doğrulaması için.
 * `firebase functions:secrets:set APPLE_ROOT_CA_CERTIFICATES_BASE64`
 */
const appleRootCertificatesBase64 = defineSecret("APPLE_ROOT_CA_CERTIFICATES_BASE64");
/**
 * Play Console'da "Play Android Developer API" erişimi verilmiş bir servis
 * hesabının indirilen JSON anahtarı, tek satır string olarak.
 * `firebase functions:secrets:set GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
 */
const googlePlayServiceAccountJson = defineSecret("GOOGLE_PLAY_SERVICE_ACCOUNT_JSON");

/**
 * F6-1d — RevenueCat kullanılmıyor: client `in_app_purchase` ile satın
 * almayı tamamladıktan sonra bu callable'ı çağırır, biz makbuzu Apple/Google'ın
 * kendi sunucu API'sine karşı doğrulayıp `gyms/{gymId}`'nin abonelik
 * alanlarını Admin SDK ile güncelleriz — client bu alanları asla doğrudan
 * yazamaz (bkz. firestore.rules `subscriptionFields()`).
 */
export const verifySubscriptionPurchase = onCall(
  { secrets: [appleRootCertificatesBase64, googlePlayServiceAccountJson] },
  async (request) => {
    const uid = request.auth?.uid;
    const role = request.auth?.token?.role as string | undefined;
    const tokenGymId = request.auth?.token?.gymId as string | undefined;
    if (!uid || role !== "admin") {
      throw new HttpsError("permission-denied", "Bu işlem için salon admin'i olarak oturum açmış olman gerekiyor.");
    }

    const gymId = typeof request.data?.gymId === "string" ? request.data.gymId : "";
    const productId = typeof request.data?.productId === "string" ? request.data.productId : "";
    const platform = request.data?.platform;
    const verificationData = typeof request.data?.verificationData === "string" ? request.data.verificationData : "";

    if (!gymId || gymId !== tokenGymId) {
      throw new HttpsError("permission-denied", "Sadece kendi salonun için abonelik doğrulaması yapabilirsin.");
    }
    if (!isKnownSubscriptionProductId(productId)) {
      throw new HttpsError("invalid-argument", `Bilinmeyen ürün: ${productId}`);
    }
    if (platform !== "ios" && platform !== "android") {
      throw new HttpsError("invalid-argument", "platform 'ios' veya 'android' olmalı.");
    }
    if (!verificationData) {
      throw new HttpsError("invalid-argument", "verificationData gerekli.");
    }

    let verified;
    try {
      verified =
        platform === "ios"
          ? await verifyAppleTransaction({
              signedTransactionInfo: verificationData,
              productId,
              rootCertificatesBase64: appleRootCertificatesBase64.value(),
            })
          : await verifyGooglePurchase({
              purchaseToken: verificationData,
              productId,
              serviceAccountJson: googlePlayServiceAccountJson.value(),
            });
    } catch (error) {
      const message = error instanceof Error ? error.message : "Bilinmeyen hata.";
      // NOT: veri objesinde `message` anahtarı KULLANMA — firebase-functions
      // logger'ı bunu kendi log satırının metniyle çakıştırıp üzerine
      // yazıyor (bir kere yaşandı, gerçek Apple/Google hata metni stack
      // trace'le değişmişti). Ayrı bir isim (`verificationErrorMessage`) kullan.
      logger.error("verifySubscriptionPurchase: makbuz doğrulanamadı", {
        gymId,
        productId,
        platform,
        verificationErrorMessage: message,
      });
      throw new HttpsError("failed-precondition", `Makbuz doğrulanamadı: ${message}`);
    }

    const status = await applySubscriptionUpdate({
      gymId,
      verified,
      productId,
      platform,
      source: "purchase",
      rawVerificationData: verificationData,
    });

    return { status, expiresAtMs: verified.expiresAtMs };
  },
);
