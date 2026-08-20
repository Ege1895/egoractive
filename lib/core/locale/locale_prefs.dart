import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcının uygulama içinden seçtiği dil override'ının yerel kalıcılığı.
/// `init()`, `main()`'de `runApp`'tan ÖNCE `await` edilmeli (bkz.
/// `RemoteConfigService.init()` ile aynı desen) — böylece [LocaleController]
/// senkron `build()` içinde [override]'ı hemen okuyabilir.
abstract final class LocalePrefs {
  static SharedPreferences? _prefs;
  static const _key = 'app_language_override';

  static Future<void> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static String? get override => _prefs?.getString(_key);

  static Future<void> setOverride(String? code) =>
      code == null ? _prefs!.remove(_key) : _prefs!.setString(_key, code);
}
