import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/badge_item.dart';
import '../service/badges_service.dart';

part 'badges_repository.g.dart';

abstract interface class BadgesRepository {
  List<BadgeItem> loadBadges();
}

class BadgesRepositoryImpl implements BadgesRepository {
  const BadgesRepositoryImpl(this._service);

  final BadgesService _service;

  @override
  List<BadgeItem> loadBadges() => _service.loadBadges();
}

@riverpod
BadgesRepository badgesRepository(BadgesRepositoryRef ref) {
  return BadgesRepositoryImpl(ref.watch(badgesServiceProvider));
}
