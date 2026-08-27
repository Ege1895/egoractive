/// F5-14 — uygulamanın kayıtlı özel URL şeması (`ios/Runner/Info.plist`
/// `CFBundleURLSchemes` ve `android/.../AndroidManifest.xml` intent-filter
/// ile birebir eşleşmeli). Teknik altyapı sabiti — Remote Config'e gitmez.
const appUrlScheme = 'egoractive';

/// Rapor mailindeki "Uygulamada Gör" butonunun açtığı host — bkz.
/// `functions/src/shared/deep-links.ts` (`REPORTS_DEEP_LINK`).
const reportsDeepLinkHost = 'reports';
