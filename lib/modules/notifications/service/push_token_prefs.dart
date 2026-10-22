import 'package:shared_preferences/shared_preferences.dart';

/// Bu CİHAZDA `users/{uid}.fcmTokens`'a en son yazılan FCM token'ı.
///
/// Token yenilendiğinde (FCM rotasyonu, uygulamanın yeniden kurulması,
/// yedekten yeni cihaza geri yükleme) `onTokenRefresh` yalnızca YENİ token'ı
/// veriyor; eskisini silebilmek için ne olduğunu bir yerde hatırlamak
/// gerekiyor. Tutulmazsa dizi her yenilemede bir eleman büyür ve hiç
/// küçülmez.
///
/// [AppPhoneFieldPrefs]/[LocalePrefs]'in aksine `main()`'de `init()`
/// beklemiyor: yalnızca push token akışında, `build()` dışında ve zaten
/// async olan bir yolda okunuyor — açılış zincirine (F10-2) yeni bir
/// `await` eklemeye gerek yok.
abstract final class PushTokenPrefs {
  static const _key = 'push_last_saved_fcm_token';

  static Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  static Future<void> write(String token) async =>
      (await SharedPreferences.getInstance()).setString(_key, token);
}
