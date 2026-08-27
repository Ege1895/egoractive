/**
 * F5-14 — uygulamanın kayıtlı özel URL şeması (bkz. `ios/Runner/Info.plist`
 * `CFBundleURLSchemes` ve `android/app/.../AndroidManifest.xml` intent-filter).
 * `AppDeepLinkService` bu şemayla gelen linkleri dinleyip ilgili panele yönlendirir.
 */
export const APP_URL_SCHEME = "egoractive";

/** Rapor mailindeki "Uygulamada Gör" butonu — admin uygulamayı açar açmaz
 * doğrudan Raporlar paneline (`AdminDashboardPanel`) düşer. */
export const REPORTS_DEEP_LINK = `${APP_URL_SCHEME}://reports`;
