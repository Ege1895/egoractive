import 'package:shared_preferences/shared_preferences.dart';

/// "Antrenörüm/Üyeyim" rol seçim ekranının ([OnboardingRolePanel]) cihazda
/// daha önce gösterilip gösterilmediğinin yerel kalıcılığı — bu ekran SADECE
/// uygulamayı ilk kez açan kullanıcıya bir kez gösterilmeli; sonrasında
/// (hesaptan çıkış yapılsa/uygulama kapatılıp açılsa bile) doğrudan
/// [PhoneLoginPanel]'e düşülmeli. `init()`, `main()`'de `runApp`'tan ÖNCE
/// `await` edilmeli (bkz. `LocalePrefs` ile aynı desen).
abstract final class OnboardingPrefs {
  static SharedPreferences? _prefs;
  static const _key = 'has_seen_role_onboarding';

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static bool get hasSeenRoleOnboarding => _prefs?.getBool(_key) ?? false;

  /// `_prefs` `init()` çağrılmadan (ör. widget testlerinde `main()` hiç
  /// çalışmadığında) `null` kalabilir — bu durumda sessizce no-op, [hasSeenRoleOnboarding]
  /// zaten `false` döndüğü için akış bozulmaz.
  static Future<void> markRoleOnboardingSeen() async =>
      _prefs?.setBool(_key, true);
}
