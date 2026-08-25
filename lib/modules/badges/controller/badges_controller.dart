import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/router/app_router.dart';
import '../domain/badge_item.dart';
import '../repository/badges_repository.dart';

part 'badges_controller.g.dart';

@riverpod
Stream<List<BadgeItem>> _badges(_BadgesRef ref) async* {
  final repository = ref.watch(badgesRepositoryProvider);
  final locale = ref.watch(localeControllerProvider);
  final uid = ref.watch(authStateProvider).valueOrNull?.uid;
  if (uid == null) {
    yield repository.buildBadges(const [], locale);
    return;
  }
  yield* repository
      .earnedBadgeIds(uid)
      .map((ids) => repository.buildBadges(ids, locale));
}

@riverpod
class BadgesController extends _$BadgesController {
  @override
  List<BadgeItem> build() => ref.watch(_badgesProvider).valueOrNull ?? const [];

  /// Stream hatası (network/izin) valueOrNull ile sessizce boş listeye
  /// düşüyordu — "hiç rozet kazanmadın" ile "yüklenemedi" ayırt edilemiyordu.
  bool get hasError => ref.watch(_badgesProvider).hasError;
}

/// Admin üye detay ekranındaki rozet bölümü — [BadgesController]'dan farklı
/// olarak oturum açan kullanıcı değil, `memberId` ile belirtilen ÜYENİN
/// rozetleri okunur. `earnedBadgeIds`/`buildBadges` zaten `uid` parametreli
/// olduğu için ek bir servis/rule değişikliği gerekmiyor — firestore.rules
/// admin'in kendi salonundaki her üyenin `users/{uid}` dokümanını zaten
/// okuyabilmesine izin veriyor.
@riverpod
Stream<List<BadgeItem>> memberBadges(MemberBadgesRef ref, String memberId) {
  final repository = ref.watch(badgesRepositoryProvider);
  final locale = ref.watch(localeControllerProvider);
  return repository
      .earnedBadgeIds(memberId)
      .map((ids) => repository.buildBadges(ids, locale));
}
