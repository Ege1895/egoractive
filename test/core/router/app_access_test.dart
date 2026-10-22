import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/router/app_access.dart';
import 'package:egoractive/core/router/app_router.dart';
import 'package:egoractive/core/theme/theme_controller.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';
import 'package:egoractive/modules/subscription/controller/subscription_controller.dart';
import 'package:egoractive/modules/subscription/domain/subscription_state.dart';

/// `appAccess` kapısının, tüm bağımlılıkları sahtelenmiş hâlde ilk kararını
/// döndürmesi. [timeout] bilerek kısa: bu testlerin asıl amacı kapının
/// DONMADIĞINI göstermek, o yüzden "yield etmedi" durumu sonsuza kadar
/// beklemek yerine hızlıca hataya dönüşmeli.
Future<AppAccess> _firstAccess({
  required AppRole? role,
  required String? gymId,
  required String? email,
  SubscriptionState? subscription,
}) async {
  final container = ProviderContainer(
    overrides: [
      currentRoleProvider.overrideWith((ref) async => role),
      activeGymIdProvider.overrideWith((ref) async => gymId),
      currentUserEmailProvider.overrideWith((ref) async => email),
      if (gymId != null)
        subscriptionStateForGymProvider(gymId).overrideWith(
          (ref) => Stream.value(subscription ?? const SubscriptionState()),
        ),
    ],
  );
  addTearDown(container.dispose);

  return container
      .read(appAccessProvider.future)
      .timeout(const Duration(seconds: 5));
}

void main() {
  group('appAccess', () {
    test('rol yoksa signedOut döner', () async {
      final access = await _firstAccess(role: null, gymId: null, email: null);
      expect(access.kind, AppAccessKind.signedOut);
      expect(access.role, isNull);
    });

    test('salonu olmayan, email\'i olmayan kullanıcı emailSetupRequired', () async {
      final access = await _firstAccess(
        role: AppRole.member,
        gymId: null,
        email: null,
      );
      expect(access.kind, AppAccessKind.emailSetupRequired);
    });

    // REGRESYON — bu dal üretimde uygulamayı KİLİTLİYORDU: `email == null`
    // kolunda abonelik köprüsünün StreamController'ı `await controller.close()`
    // ile kapatılıyordu, ama o controller'ı dinleyen `yield* controller.stream`
    // satırına hiç varılmadığı için `close()`'un future'ı asla tamamlanmıyor
    // ve generator hiçbir zaman yield etmiyordu. Kullanıcı OTP'yi doğru girip
    // oturumu açtığı hâlde "Kodu gir" ekranında sonsuza kadar kalıyordu
    // (2026-09-27, üretim buildi). Buradaki `timeout` o donmayı yakalar.
    test(
      'salonu OLAN ama email\'i olmayan kullanıcıda donmadan emailSetupRequired döner',
      () async {
        final access = await _firstAccess(
          role: AppRole.admin,
          gymId: 'gym-1',
          email: null,
        );
        expect(access.kind, AppAccessKind.emailSetupRequired);
        expect(access.role, AppRole.admin);
      },
    );

    test('abonelik muafiyeti olan salonda ready döner', () async {
      final access = await _firstAccess(
        role: AppRole.admin,
        gymId: 'gym-1',
        email: 'admin@example.com',
        subscription: const SubscriptionState(
          status: SubscriptionStatus.expired,
          subscriptionExempt: true,
        ),
      );
      expect(access.kind, AppAccessKind.ready);
    });

    test('aboneliği biten antrenör blocked olur', () async {
      final access = await _firstAccess(
        role: AppRole.trainer,
        gymId: 'gym-1',
        email: 'trainer@example.com',
        subscription: const SubscriptionState(
          status: SubscriptionStatus.expired,
        ),
      );
      expect(access.kind, AppAccessKind.blocked);
    });
  });
}
