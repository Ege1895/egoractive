import { getFirestore, Timestamp } from "firebase-admin/firestore";
import { defineSecret } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/v2/https";

import { gymDoc } from "../shared/firestore-paths";
import { isKnownSubscriptionProductId } from "../shared/subscription-constants";
import { verifyAppleReceipt, verifyGooglePurchase } from "../shared/subscription-verification";

/**
 * App Store Connect > Subscriptions > "App-Specific Shared Secret".
 * `firebase functions:secrets:set APPLE_SUBSCRIPTION_SHARED_SECRET`
 */
const appleSharedSecret = defineSecret("APPLE_SUBSCRIPTION_SHARED_SECRET");
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
  { secrets: [appleSharedSecret, googlePlayServiceAccountJson] },
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
          ? await verifyAppleReceipt({
              receiptData: verificationData,
              productId,
              sharedSecret: appleSharedSecret.value(),
            })
          : await verifyGooglePurchase({
              purchaseToken: verificationData,
              productId,
              serviceAccountJson: googlePlayServiceAccountJson.value(),
            });
    } catch (error) {
      const message = error instanceof Error ? error.message : "Bilinmeyen hata.";
      throw new HttpsError("failed-precondition", `Makbuz doğrulanamadı: ${message}`);
    }

    await getFirestore()
      .doc(gymDoc(gymId))
      .update({
        subscriptionStatus: verified.isActive ? "active" : "expired",
        subscriptionExpiresAt: Timestamp.fromMillis(verified.expiresAtMs),
        subscriptionStartedAt: Timestamp.fromMillis(verified.startAtMs),
        subscriptionProductId: productId,
        subscriptionPlatform: platform,
      });

    return { status: verified.isActive ? "active" : "expired", expiresAtMs: verified.expiresAtMs };
  },
);
