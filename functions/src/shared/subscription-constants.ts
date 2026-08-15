/**
 * `lib/core/constants/subscription_constants.dart`'taki ürün kimlikleriyle
 * birebir eşleşmeli — App Store Connect / Play Console'da yeni bir ürün
 * tanımlandığında ikisi birlikte güncellenir.
 */
export const SUBSCRIPTION_PRODUCT_IDS = ["egoractive_gym_monthly", "egoractive_gym_yearly"] as const;

export type SubscriptionProductId = (typeof SUBSCRIPTION_PRODUCT_IDS)[number];

export function isKnownSubscriptionProductId(productId: string): productId is SubscriptionProductId {
  return (SUBSCRIPTION_PRODUCT_IDS as readonly string[]).includes(productId);
}

/** Apple App Store Connect'teki bundle ID / Google Play Console paket adı. */
export const IOS_BUNDLE_ID = "com.egoragames.egoractive";
export const ANDROID_PACKAGE_NAME = "com.egoragames.egoractive";
