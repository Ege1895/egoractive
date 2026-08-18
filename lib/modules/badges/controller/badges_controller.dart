import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/badge_item.dart';
import '../repository/badges_repository.dart';

part 'badges_controller.g.dart';

@riverpod
Stream<List<BadgeItem>> _badges(_BadgesRef ref) async* {
  final repository = ref.watch(badgesRepositoryProvider);
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) {
    yield repository.buildBadges(const []);
    return;
  }
  yield* repository.earnedBadgeIds(uid).map(repository.buildBadges);
}

@riverpod
class BadgesController extends _$BadgesController {
  @override
  List<BadgeItem> build() => ref.watch(_badgesProvider).valueOrNull ?? const [];

  /// Stream hatası (network/izin) valueOrNull ile sessizce boş listeye
  /// düşüyordu — "hiç rozet kazanmadın" ile "yüklenemedi" ayırt edilemiyordu.
  bool get hasError => ref.watch(_badgesProvider).hasError;
}
