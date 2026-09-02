import 'package:flutter/foundation.dart';

/// F10-1 — performans baseline ölçümü. FAZ 10'daki optimizasyonların
/// (F10-2 `runApp()` blokajı, F10-3 `appAccess` paralelleştirme, F10-4
/// codebase bölme) gerçekten işe yaradığını KANITLAYABİLMEK için, her
/// görevden önce ve sonra aynı akışları ölçüp karşılaştırıyoruz.
///
/// Kullanım (gerçek cihazda, **mobil veriyle** — WiFi'da fark küçük
/// görünür, asıl sorun mobilde):
/// ```
/// flutter run --profile
/// # başka bir terminalde:
/// flutter logs | grep PERF
/// ```
///
/// Release build'de tamamen no-op — hiçbir `Stopwatch` çalışmaz, hiçbir
/// çıktı üretilmez, dolayısıyla production performansına etkisi yoktur.
class PerfTrace {
  const PerfTrace._();

  /// `main()`'in ilk satırından itibaren geçen süre — "uygulama açılış →
  /// ilk kare" ölçümünün referans noktası.
  static Stopwatch? _appStart;

  static final Map<String, Stopwatch> _spans = {};

  /// `main()`'in EN BAŞINDA çağrılmalı (Firebase init'ten bile önce).
  static void startApp() {
    if (kReleaseMode) return;
    _appStart = Stopwatch()..start();
    _log('APP START');
  }

  /// Adlandırılmış bir ölçümü başlatır. Aynı ad iki kez `begin` edilirse
  /// ikincisi birinciyi sıfırlar (ör. kullanıcı aynı akışı tekrar dener).
  static void begin(String name) {
    if (kReleaseMode) return;
    _spans[name] = Stopwatch()..start();
  }

  /// [begin] ile başlatılan ölçümü bitirir ve süreyi yazar. Hiç `begin`
  /// edilmemiş bir ad için sessizce hiçbir şey yapmaz — ölçüm kodunun
  /// kendisi asla uygulamayı bozmamalı.
  static void end(String name) {
    if (kReleaseMode) return;
    final span = _spans.remove(name);
    if (span == null) return;
    span.stop();
    _log('$name: ${span.elapsedMilliseconds} ms');
  }

  /// `main()` başlangıcından bu ana kadar geçen toplam süre — ilk kare,
  /// login sonrası ana ekranın açılması gibi "uygulama açılışına göre"
  /// anlamlı olan kilometre taşları için.
  static void sinceAppStart(String label) {
    if (kReleaseMode) return;
    final elapsed = _appStart?.elapsedMilliseconds;
    if (elapsed == null) return;
    _log('$label (app start\'tan beri): $elapsed ms');
  }

  static void _log(String message) => debugPrint('[PERF] $message');
}
