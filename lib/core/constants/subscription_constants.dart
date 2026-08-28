/// F6-1 — App Store Connect / Play Console'da tanımlanan salon abonelik
/// ürün kimlikleri. Değiştirmek yeni bir mağaza ürünü tanımlamayı
/// gerektirdiğinden Remote Config'e değil, buraya sabitlenir.
const gymMonthlySubscriptionProductId = 'egoractive_business_monthly';
const gymYearlySubscriptionProductId = 'egoractive_business_yearly';

const gymSubscriptionProductIds = {gymMonthlySubscriptionProductId, gymYearlySubscriptionProductId};

/// `functions/src/shared/subscription-constants.ts`'teki `ANDROID_PACKAGE_NAME`
/// ile birebir eşleşmeli — Play Store abonelik yönetimi derin bağlantısı
/// (`SubscriptionPanel`'deki "Aboneliği yönet") için gerekiyor.
const androidPackageName = 'com.egoragames.egoractive';
