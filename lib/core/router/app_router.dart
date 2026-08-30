import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../panels/base_panel.dart';
import '../panels/shell/admin_shell_panel.dart';
import '../panels/shell/member_shell_panel.dart';
import '../panels/shell/trainer_shell_panel.dart';

part 'app_router.g.dart';

/// F1-11 — Rol bazlı yönlendirme iskeleti. Firebase Auth custom claim'indeki
/// `role` alanına göre 3 boş shell'den birine çözümlenir.
///
/// Bu dosya şimdilik `PanelStackController` üzerinden doğrudan yönlendiriyor
/// (main.dart'taki global dinleyici). CLAUDE.md §2.3'teki go_router katmanı
/// (deep link/web URL senkronizasyonu) bunun üzerine ayrı bir adımda ince bir
/// katman olarak eklenecek — iş mantığı burada, router'da yaşamıyor.
enum AppRole { admin, trainer, member }

BasePanel shellForRole(AppRole role) => switch (role) {
  AppRole.admin => const AdminShellPanel(),
  AppRole.trainer => const TrainerShellPanel(),
  AppRole.member => const MemberShellPanel(),
};

/// Custom claim map'inden `role` alanını okur; tanınmayan/eksik değerde
/// `null` döner (kabul kriteri: "custom claim yoksa/geçersizse login
/// ekranına geri atılıyor").
AppRole? roleFromClaims(Map<String, dynamic>? claims) {
  return switch (claims?['role']) {
    'admin' => AppRole.admin,
    'trainer' => AppRole.trainer,
    'member' => AppRole.member,
    _ => null,
  };
}

@riverpod
Stream<User?> authState(AuthStateRef ref) =>
    FirebaseAuth.instance.authStateChanges();

/// `role` (bu dosyada) ve `gymId` (`theme_controller.dart`'taki
/// `activeGymIdProvider`) aynı custom claim map'inin iki farklı alanı —
/// ikisi de `getIdTokenResult()`'a bağımlı. Önceden her biri KENDİ
/// `getIdTokenResult()` çağrısını yapıyordu; `appAccessProvider` da bunları
/// ardışık `await`ediyordu (role bitmeden gymId isteği hiç başlamıyordu) —
/// yani her uygulama açılışında aynı token için iki ayrı round-trip.
/// Riverpod aynı provider'ı izleyen tüm taraflar arasında sonucu
/// memoize ettiği için burada TEK bir çağrıya indirgemek, `currentRole` ve
/// `activeGymId`'nin ikisinin de aynı (tek) fetch'i paylaşmasını sağlıyor.
@riverpod
Future<IdTokenResult?> authIdTokenResult(AuthIdTokenResultRef ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;
  return user.getIdTokenResult();
}

/// Oturum yoksa `null`. Oturum varsa ID token'ı okuyup rolü çözer — token
/// custom claim taşımıyorsa/claim geçersizse de `null` döner.
@riverpod
Future<AppRole?> currentRole(CurrentRoleRef ref) async {
  final tokenResult = await ref.watch(authIdTokenResultProvider.future);
  if (tokenResult == null) return null;
  return roleFromClaims(tokenResult.claims);
}
