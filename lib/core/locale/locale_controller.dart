import 'dart:ui' show PlatformDispatcher;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'locale_prefs.dart';

part 'locale_controller.g.dart';

/// Uygulamanın aktif dili (`'tr'`/`'en'`). Kullanıcı hiç seçim yapmadıysa
/// cihaz diline düşer (F1 kabul kriteri: ilk açılışta OS dili tr ise tr,
/// değilse en); kullanıcı [setLanguage] ile bir kez seçim yapınca
/// [LocalePrefs] üzerinden kalıcı olur. Bu provider'ı `watch` eden her widget
/// dil değişince otomatik yeniden çizilir (bkz. `rcTextProvider`).
@Riverpod(keepAlive: true)
class LocaleController extends _$LocaleController {
  @override
  String build() => LocalePrefs.override ?? _deviceLanguageCode();

  static String _deviceLanguageCode() =>
      PlatformDispatcher.instance.locale.languageCode == 'tr' ? 'tr' : 'en';

  Future<void> setLanguage(String code) async {
    await LocalePrefs.setOverride(code);
    state = code;
  }
}
