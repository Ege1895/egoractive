/**
 * `lib/core/constants/subscription_constants.dart`'taki ürün kimlikleriyle
 * birebir eşleşmeli — App Store Connect / Play Console'da yeni bir ürün
 * tanımlandığında ikisi birlikte güncellenir.
 */
export const SUBSCRIPTION_PRODUCT_IDS = ["egoractive_business_monthly", "egoractive_business_yearly"] as const;

export type SubscriptionProductId = (typeof SUBSCRIPTION_PRODUCT_IDS)[number];

export function isKnownSubscriptionProductId(productId: string): productId is SubscriptionProductId {
  return (SUBSCRIPTION_PRODUCT_IDS as readonly string[]).includes(productId);
}

/** Apple App Store Connect'teki bundle ID / Google Play Console paket adı. */
export const IOS_BUNDLE_ID = "com.egoragames.egoractive";
export const ANDROID_PACKAGE_NAME = "com.egoragames.egoractive";

/**
 * App Store Connect'teki uygulamanın sayısal Apple ID'si (URL'de
 * `appstoreconnect.apple.com/apps/{APPLE_APP_ID}/...` olarak görünür) —
 * `SignedDataVerifier`'ın `Environment.PRODUCTION` doğrulaması için zorunlu
 * (bkz. `@apple/app-store-server-library`).
 */
export const APPLE_APP_ID = 6802342121;
