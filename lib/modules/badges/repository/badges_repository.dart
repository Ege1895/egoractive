import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/badge_item.dart';
import '../service/badges_service.dart';

part 'badges_repository.g.dart';

abstract interface class BadgesRepository {
  List<BadgeItem> buildBadges(List<String> earnedIds, String locale);
  Stream<List<String>> earnedBadgeIds(String uid);
}

class BadgesRepositoryImpl implements BadgesRepository {
  const BadgesRepositoryImpl(this._service);

  final BadgesService _service;

  @override
  List<BadgeItem> buildBadges(List<String> earnedIds, String locale) =>
      _service.buildBadges(earnedIds, locale);

  @override
  Stream<List<String>> earnedBadgeIds(String uid) =>
      _service.earnedBadgeIds(uid);
}

@riverpod
BadgesRepository badgesRepository(BadgesRepositoryRef ref) {
  return BadgesRepositoryImpl(ref.watch(badgesServiceProvider));
}
