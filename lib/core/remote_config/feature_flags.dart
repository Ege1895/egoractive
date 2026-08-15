import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'remote_config_service.dart';

part 'feature_flags.g.dart';

/// F5-5 — koddaki her feature flag kontrol noktası burada toplanır. Kod
/// içinde dağınık `remoteConfigService.featureFlags['...']` çağrıları
/// yerine bu dosyadaki isimlendirilmiş getter'lar kullanılır. `cfg_feature_flags`
/// RC'de tek bir JSON obje (`{"flag_key": true}`) — yeni bir flag eklemek
/// veya kaldırmak sadece bu dosyayı değiştirir (kabul kriteri).
class FeatureFlags {
  const FeatureFlags(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  /// Grup dersleri özelliği: Keşfet'teki "Grup dersleri" sekmesi, antrenörün
  /// takviminden grup dersi oluşturma, admin'in Ayarlar > Grup dersleri
  /// girişi. Kapatıldığında bu üç giriş noktası da gizlenir — kod
  /// değişikliği/store güncellemesi gerekmeden anlık devre dışı bırakılabilir.
  bool get isGroupSessionsEnabled => _flag('group_sessions_enabled', true);

  /// RC henüz hazır olmadığı (ör. Firebase başlatılmamış test ortamı)
  /// durumlarda widget'ı çökertmemek için burada savunmacı: hata olursa
  /// varsayılana düşer. Bu sayede çağıran taraflar `featureFlagsProvider`'ı
  /// doğrudan senkron okuyabiliyor, ayrı bir async-wrapped provider'a gerek
  /// kalmıyor.
  bool _flag(String key, bool fallback) {
    try {
      final value = _remoteConfig.featureFlags[key];
      return value is bool ? value : fallback;
    } on Exception {
      return fallback;
    }
  }
}

@riverpod
FeatureFlags featureFlags(FeatureFlagsRef ref) => FeatureFlags(ref.watch(remoteConfigServiceProvider));
