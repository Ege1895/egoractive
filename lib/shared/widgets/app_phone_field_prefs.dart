import 'package:shared_preferences/shared_preferences.dart';

/// F8-5 — `AppPhoneField`'da son seçilen ülkenin yerel kalıcılığı; kullanıcı
/// her telefon girişinde TR'den başlamak zorunda kalmasın diye. `init()`,
/// `main()`'de `runApp`'tan ÖNCE `await` edilmeli (bkz. `LocalePrefs` ile
/// aynı desen) — böylece [lastCountryIso] senkron `build()` içinde hemen
/// okunabilir. [setLastCountryIso] her `AppPhoneField.onChanged`
/// tetiklenişinde (yani her tuş vuruşunda) çağrıldığından — `LocalePrefs`'in
/// aksine, sadece kullanıcı bilinçli bir dil seçimi yaptığında çağrılan
/// nadir bir eylem değil — `init()` henüz çağrılmamışsa (örn. `main()`'den
/// geçmeyen widget testleri) sessizce no-op olur, `LocalePrefs` gibi patlamaz.
abstract final class AppPhoneFieldPrefs {
  static SharedPreferences? _prefs;
  static const _key = 'app_phone_field_last_country_iso';

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static String? get lastCountryIso => _prefs?.getString(_key);

  static Future<void> setLastCountryIso(String isoCode) async =>
      _prefs?.setString(_key, isoCode);
}
