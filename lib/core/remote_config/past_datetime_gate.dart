import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'remote_config_service.dart';

/// Seans/grup dersi/etkinlik oluşturma ekranlarının ortak kontrolü — RC'deki
/// `cfg_allow_past_datetime_creation` testte açılmadıkça şu andan eski bir
/// tarih/saate yeni içerik oluşturulmasına izin vermez.
bool isPastDatetimeCreationBlocked(WidgetRef ref, DateTime dateTime) {
  if (ref.read(remoteConfigServiceProvider).allowPastDatetimeCreation) {
    return false;
  }
  return dateTime.isBefore(DateTime.now());
}
