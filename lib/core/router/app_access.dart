import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../modules/auth/repository/auth_repository.dart';
import '../../modules/subscription/controller/subscription_controller.dart';
import '../../modules/subscription/domain/subscription_state.dart';
import '../onboarding/onboarding_prefs.dart';
import '../remote_config/remote_config_service.dart';
import '../theme/theme_controller.dart';
import 'app_router.dart';

part 'app_access.g.dart';

enum AppAccessKind {
  /// Oturum yok (ya da rol/claim geçersiz) — girişe dönülür.
  signedOut,

  /// Egoractive Authentication Sistemi §6 — oturum açık ama
  /// `users/{uid}.email` boş (admin tarafından oluşturulmuş, hiç aktive
  /// olmamış bir hesap ya da email eklenmemiş eski bir hesap). Role/salon
  /// kontrolünden ÖNCE gelir — email zorunlu kimlik parçası olduğu için.
  emailSetupRequired,

  /// Antrenör/üye, salonun aboneliği `trial`/`active` değilken oturumu
  /// açık kalmış (ör. uygulama açıkken abonelik sona erdi) — çıkış
  /// yaptırılıp bilgilendirici bir mesajla girişe dönülür.
  blocked,

  /// Admin, salonun aboneliği `trial`/`active` değil — zorunlu abonelik
  /// ekranına yönlendirilir (ilk kurulum ya da yeniden abone olma).
  subscriptionOnboarding,

  /// Normal erişim — role uygun shell açılır.
  ready,
}

typedef AppAccess = ({AppAccessKind kind, AppRole? role});

/// Salon Abonelik ve Erişim Akışı — tek reaktif erişim kararı kaynağı.
/// Önceki tek seferlik (Future tabanlı) rol kontrolünün yerini alır: rol
/// DEĞİŞTİĞİNDE olduğu kadar, salonun `subscriptionStatus`'u CANLI olarak
/// değiştiğinde de (uygulama açıkken trial biterse/abone olunursa) tepki
/// verir — `subscriptionStatus` bir custom claim değil canlı bir Firestore
/// alanı olduğu için token'ın yenilenmesini beklemeye gerek yok.
///
/// Salonun abonelik durumu `subscriptionStateForGymProvider` üzerinden
/// izlenir — `SubscriptionController` da AYNI provider'ı izliyor (bkz. o
/// dosyadaki yorum), aynı `gyms/{gymId}` dokümanı için iki ayrı Firestore
/// listener'ı açılmasın diye. Buradaki `ref.listen(..., fireImmediately: true)`
/// köprüsü BİLEREK kullanılıyor (`ref.watch` + "veri gelene kadar hiç yield
/// etme" yaklaşımı yerine): `ref.listen`'in geri çağırması provider'ın HER
/// durum geçişinde (loading→data, data→data, data→error) kesin olarak
/// tetiklenir — ilk sürümde "hâlâ loading'ken hiç yield etmeden dön"
/// deseni, veri geldiğinde üst provider'ın yeniden tetiklenmesine
/// güveniyordu ve gerçek bir cihazda kalıcı bir giriş kilitlenmesine yol
/// açtı (bkz. "Çmt Saloon" salonu, 2026-08-26) — kesin kaynağı doğrulanamadı
/// ama bu köprü, aynı belirsizliğe bağlı kalmadan sorunu ortadan kaldırıyor.
@riverpod
Stream<AppAccess> appAccess(AppAccessRef ref) async* {
  final role = await ref.watch(currentRoleProvider.future);
  debugPrint('[appAccess] role=$role');
  if (role == null) {
    yield (kind: AppAccessKind.signedOut, role: null);
    return;
  }
  // Geçerli bir role bağlanmış bir Firebase Auth oturumu — cihazın hayatında
  // İLK KEZ burası çözülüyorsa bu, "başarılı ilk giriş" anı (bkz.
  // `OnboardingPrefs` dokümantasyonu — kıstas rol seçim ekranını GÖRMÜŞ
  // olmak değil, bir girişi TAMAMLAMIŞ olmak).
  unawaited(OnboardingPrefs.markFirstLoginCompleted());

  // Egoractive Authentication Sistemi §6 — email custom claim olmadığı için
  // (sadece OTP doğrulaması sonrası Cloud Function tarafından yazılan bir
  // Firestore alanı) tek seferlik bir okuma yeterli; `EmailSetupPanel`
  // doğrulama başarılı olunca bu provider'ı `ref.invalidate` ile elle
  // tazeler (bkz. `otp_verification_panel.dart`).
  final email = await ref.watch(currentUserEmailProvider.future);
  debugPrint('[appAccess] email=${email == null ? null : "set"}');
  if (email == null) {
    yield (kind: AppAccessKind.emailSetupRequired, role: role);
    return;
  }

  final gymId = await ref.watch(activeGymIdProvider.future);
  debugPrint('[appAccess] gymId=$gymId');
  if (gymId == null) {
    yield (kind: AppAccessKind.ready, role: role);
    return;
  }

  final controller = StreamController<AppAccess>();
  final subscription = ref.listen(subscriptionStateForGymProvider(gymId), (
    previous,
    next,
  ) {
    debugPrint(
      '[appAccess] subscription update isLoading=${next.isLoading} '
      'hasError=${next.hasError} error=${next.error} value=${next.valueOrNull}',
    );
    next.whenData((state) {
      final active =
          state.subscriptionExempt ||
          state.status == SubscriptionStatus.trial ||
          state.status == SubscriptionStatus.active;
      if (active) {
        controller.add((kind: AppAccessKind.ready, role: role));
        return;
      }
      if (role != AppRole.admin) {
        controller.add((kind: AppAccessKind.blocked, role: role));
        return;
      }
      // `requireSubscriptionOnboarding` SADECE admin'in bu ekrana zorunlu
      // yönlendirilip yönlendirilmeyeceğini kontrol eder (mağaza ürünleri
      // canlı olana kadar Console'dan false tutulabilir, bkz.
      // RemoteConfigKeys.requireSubscriptionOnboarding) — antrenör/üye
      // login kapısı (`requestCustomToken`) ve Firestore read gating bu
      // bayraktan bağımsız, her zaman geçerlidir.
      final onboardingRequired = ref
          .read(remoteConfigServiceProvider)
          .requireSubscriptionOnboarding;
      controller.add(
        onboardingRequired
            ? (kind: AppAccessKind.subscriptionOnboarding, role: role)
            : (kind: AppAccessKind.ready, role: role),
      );
    });
  }, fireImmediately: true);

  ref.onDispose(() {
    subscription.close();
    controller.close();
  });

  yield* controller.stream;
}
