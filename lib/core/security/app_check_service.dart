import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

/// F13-5 — App Check: isteklerin gerçekten BU uygulamadan geldiğini
/// doğrular. Kurulu olmadığı sürece callable'lar (`startLogin`,
/// `listPartnerGyms`, `signupGymAdmin` …), Firestore ve Storage, proje
/// yapılandırmasını eline geçiren herkes tarafından doğrudan çağrılabilir —
/// denetimde `deleteAccount` uç noktasına gelen kimliksiz bir GET isteği
/// loglarda görülmüştü.
///
/// ⚠️ ZORUNLU KILMA (enforcement) BU KODLA AÇILMAZ, Firebase Console'dan
/// servis servis açılır. Sıra bilinçli: önce bu istemci kodu yayına
/// çıkmalı, Console'da "monitoring" modunda doğrulanmamış istek oranı
/// izlenmeli ve o oran düşünce enforcement açılmalı. Tersi yapılırsa
/// mağazadaki ESKİ sürümler (App Check token'ı göndermeyen) anında
/// kilitlenir.
///
/// Başlatma hiçbir koşulda uygulamayı düşürmez: App Check kurulamazsa
/// (ağ yok, cihaz doğrulaması başarısız) uygulama App Check'siz çalışmaya
/// devam eder — enforcement açılana kadar zaten bir şey değişmez.
abstract final class AppCheckService {
  static Future<void> activate() async {
    try {
      await FirebaseAppCheck.instance.activate(
        // Debug build'lerde gerçek cihaz doğrulaması çalışmaz (emülatör,
        // imzasız build). Debug provider konsola bir token yazar, o token
        // Firebase Console'a elle eklenir. Release'de ASLA kullanılmaz:
        // debug token'ı sızarsa App Check'in tüm anlamı kaybolur.
        providerAndroid: kDebugMode
            ? AndroidDebugProvider()
            : AndroidPlayIntegrityProvider(),
        // iOS'ta App Attest ayrı bir capability istiyor; DeviceCheck ek
        // kurulum gerektirmiyor ve iOS 15 tabanımızda her cihazda çalışıyor.
        providerApple: kDebugMode
            ? AppleDebugProvider()
            : AppleDeviceCheckProvider(),
      );
    } on Exception catch (error) {
      debugPrint('App Check etkinleştirilemedi: $error');
    }
  }
}
