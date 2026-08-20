import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../domain/badge_item.dart';

part 'badges_service.g.dart';

/// F4-4 — rozet tanımları Remote Config'ten okunur (kodda değil), hangi
/// rozetlerin kazanıldığı `badgeCheck` scheduled function'ının `users/{uid}.badges`
/// alanına yazdığı id listesinden gelir.
class BadgesService {
  const BadgesService(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  List<BadgeItem> buildBadges(List<String> earnedIds, String locale) {
    return _remoteConfig.badgeCriteria.map((criterion) {
      final id = criterion['id'] as String? ?? '';
      return BadgeItem(
        id: id,
        title: (criterion['title_$locale'] as String?) ?? '',
        note: (criterion['note_$locale'] as String?) ?? '',
        earned: earnedIds.contains(id),
      );
    }).toList();
  }

  Stream<List<String>> earnedBadgeIds(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map(
          (doc) =>
              List<String>.from(doc.data()?['badges'] as List? ?? const []),
        );
  }
}

@riverpod
BadgesService badgesService(BadgesServiceRef ref) =>
    BadgesService(ref.watch(remoteConfigServiceProvider));
