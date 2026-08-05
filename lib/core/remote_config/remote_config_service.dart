import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remote_config_service.g.dart';

/// Remote Config parametre anahtarları (CLAUDE.md §2.5 — runtime'da
/// değişebilecek iş kuralı değerleri buradan okunur).
abstract final class RemoteConfigKeys {
  static const sessionReminderMinutesBefore = 'sessionReminderMinutesBefore';
  static const defaultGroupSessionCapacity = 'defaultGroupSessionCapacity';
  static const feedbackReminderDayOfMonth = 'feedbackReminderDayOfMonth';
  static const freeVersionAdsEnabled = 'freeVersionAdsEnabled';
  static const featureFlags = 'featureFlags';
}

/// Firebase Remote Config'e tip güvenli erişim katmanı. `FirebaseRemoteConfig.instance`
/// bu dosya dışında hiçbir yerde çağrılmaz (CLAUDE.md §2.5).
class RemoteConfigService {
  const RemoteConfigService();

  static const Map<String, Object> _defaults = {
    RemoteConfigKeys.sessionReminderMinutesBefore: 60,
    RemoteConfigKeys.defaultGroupSessionCapacity: 6,
    RemoteConfigKeys.feedbackReminderDayOfMonth: -1,
    RemoteConfigKeys.freeVersionAdsEnabled: true,
    RemoteConfigKeys.featureFlags: '{}',
  };

  int get sessionReminderMinutesBefore => getInt(RemoteConfigKeys.sessionReminderMinutesBefore);

  int get defaultGroupSessionCapacity => getInt(RemoteConfigKeys.defaultGroupSessionCapacity);

  /// Ayın son günü için -1 döner (ör. Şubat'ta 28/29'u sabit kodlamamak için).
  int get feedbackReminderDayOfMonth => getInt(RemoteConfigKeys.feedbackReminderDayOfMonth);

  bool get freeVersionAdsEnabled => getBool(RemoteConfigKeys.freeVersionAdsEnabled);

  /// Ham JSON'u map'e çevirir; parse hatasında veya boşsa boş obje döner —
  /// tek bir bozuk RC değeri yüzünden uygulama çökmez.
  Map<String, dynamic> get featureFlags {
    final raw = getString(RemoteConfigKeys.featureFlags);
    if (raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : const {};
    } on FormatException {
      return const {};
    }
  }

  /// Uygulama açılışında bir kez çağrılır: varsayılanları ayarlar, sonra
  /// fetch+activate dener. İnternet yoksa/başarısız olursa varsayılanlarla
  /// devam eder — uygulama hiçbir zaman bu yüzden çökmez.
  Future<void> init() async {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await rc.setDefaults(_defaults);
    try {
      await rc.fetchAndActivate();
    } on Exception {
      // Fetch başarısız oldu — setDefaults'taki değerler geçerliliğini korur.
    }
  }

  int getInt(String key) => FirebaseRemoteConfig.instance.getInt(key);

  bool getBool(String key) => FirebaseRemoteConfig.instance.getBool(key);

  String getString(String key) => FirebaseRemoteConfig.instance.getString(key);

  double getDouble(String key) => FirebaseRemoteConfig.instance.getDouble(key);
}

@Riverpod(keepAlive: true)
RemoteConfigService remoteConfigService(RemoteConfigServiceRef ref) => const RemoteConfigService();
