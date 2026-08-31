import 'package:shared_preferences/shared_preferences.dart';

/// "Antrenörüm/Üyeyim" rol seçim ekranının ([OnboardingRolePanel]) cihazda
/// bir daha gösterilip gösterilmeyeceğinin yerel kalıcılığı. Kıstas
/// kullanıcının bu ekranı DAHA ÖNCE GÖRMÜŞ olması değil, cihazda hiç
/// tamamlanmış bir girişi (rolü geçerli bir custom claim'e bağlanmış bir
/// Firebase Auth oturumu — bkz. `appAccess`'in `role != null` anı) OLUP
/// olmadığıdır. Kullanıcı rol seçip telefon/salon kurulumu akışına girse
/// bile OTP doğrulamasını tamamlamadan uygulamayı kapatırsa, bir sonraki
/// açılışta yine bu ekrandan başlamalı — aksi halde (bir hata/donma sonrası
/// zorla kapatma dahil) doğrudan telefon girişine düşer ve kullanıcı rol
/// seçimini bir daha asla göremez. `init()`, `main()`'de `runApp`'tan ÖNCE
/// `await` edilmeli (bkz. `LocalePrefs` ile aynı desen).
abstract final class OnboardingPrefs {
  static SharedPreferences? _prefs;
  static const _key = 'has_completed_first_login';

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static bool get hasCompletedFirstLogin => _prefs?.getBool(_key) ?? false;

  /// `_prefs` `init()` çağrılmadan (ör. widget testlerinde `main()` hiç
  /// çalışmadığında) `null` kalabilir — bu durumda sessizce no-op,
  /// [hasCompletedFirstLogin] zaten `false` döndüğü için akış bozulmaz.
  static Future<void> markFirstLoginCompleted() async =>
      _prefs?.setBool(_key, true);
}
