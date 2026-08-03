import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/badge_item.dart';
import '../repository/badges_repository.dart';

part 'badges_controller.g.dart';

@riverpod
class BadgesController extends _$BadgesController {
  @override
  List<BadgeItem> build() => ref.watch(badgesRepositoryProvider).loadBadges();
}
