import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/badge_item.dart';

part 'badges_service.g.dart';

/// Mock servis — F4-4'te `users/{uid}.badges` alanına bağlanacak (rozet
/// kriterleri kodda değil Remote Config'te tanımlı olacak).
class BadgesService {
  const BadgesService();

  List<BadgeItem> loadBadges() {
    return const [
      BadgeItem(title: 'İlk dersin', note: '14 Haziran', earned: true),
      BadgeItem(title: '5 ders tamam', note: '19 Temmuz', earned: true),
      BadgeItem(title: 'İlk ölçümün', note: '19 Nisan', earned: true),
      BadgeItem(title: 'Hiç iptal yok', note: 'Haziran ayı', earned: true),
      BadgeItem(title: '20 ders tamam', note: '14 ders kaldı', earned: false),
      BadgeItem(title: 'Grup dersi', note: 'Bir grup dersine katıl', earned: false),
      BadgeItem(title: 'Etkinlik', note: 'Bir etkinliğe katıl', earned: false),
      BadgeItem(title: '6 ay üyelik', note: '2 ay kaldı', earned: false),
      BadgeItem(title: 'Ölçüm serisi', note: '3 ay üst üste ölç', earned: false),
    ];
  }
}

@riverpod
BadgesService badgesService(BadgesServiceRef ref) => const BadgesService();
