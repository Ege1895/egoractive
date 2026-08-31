import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/auth/controller/auth_controller.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';

/// Gerçek Firebase çağrısı yapmayan sahte repository — bu dosya controller'ın
/// state geçişlerini test eder, Firebase entegrasyonunu değil.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<StartLoginResult> startLogin({
    required String identifierType,
    required String value,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return (needsEmailSetup: false, uid: 'uid-1', email: 'a@b.com');
  }

  @override
  Future<void> verifyLoginOtp({required String uid, required String code}) =>
      Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> sendEmailSetupOtp({
    required String uid,
    required String email,
  }) => Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> verifyEmailSetupOtp({
    required String uid,
    required String code,
  }) => Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> sendEmailChangeOtp(String newEmail) =>
      Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> verifyEmailChangeOtp(String code) =>
      Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> deleteAccount() =>
      Future<void>.delayed(const Duration(seconds: 2));

  @override
  Future<void> signOut() async {}
}

void main() {
  group('AuthController', () {
    test('setPhone stores the E.164 value and validity from AppPhoneField', () {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      notifier.setPhone('+905324187605', isValid: true);
      expect(container.read(authControllerProvider).phoneE164, '+905324187605');
      expect(container.read(authControllerProvider).isPhoneComplete, isTrue);

      notifier.setPhone('+9053241876', isValid: false);
      expect(container.read(authControllerProvider).phoneE164, '+9053241876');
      expect(container.read(authControllerProvider).isPhoneComplete, isFalse);
    });

    test('setPhone clears a previous login error', () {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      notifier.setPhone('+90', isValid: false);
      notifier.setPhone('+905324187605', isValid: true);
      expect(container.read(authControllerProvider).loginErrorMessage, isNull);
      expect(container.read(authControllerProvider).loginErrorReason, isNull);
    });

    test('startLogin is a no-op until the phone number is complete', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.startLogin(identifierType: 'phone');
      expect(container.read(authControllerProvider).isRequestingLogin, isFalse);
    });

    test('startLogin toggles isRequestingLogin around the mock call', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      notifier.setPhone('+905324187605', isValid: true);

      final future = notifier.startLogin(identifierType: 'phone');
      expect(container.read(authControllerProvider).isRequestingLogin, isTrue);
      await future;
      expect(container.read(authControllerProvider).isRequestingLogin, isFalse);
    });

    test('deleteAccount requires acknowledgement first', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.deleteAccount();
      expect(container.read(authControllerProvider).isDeletingAccount, isFalse);

      notifier.toggleDeleteAcknowledged();
      expect(
        container.read(authControllerProvider).deleteAccountAcknowledged,
        isTrue,
      );

      final future = notifier.deleteAccount();
      expect(container.read(authControllerProvider).isDeletingAccount, isTrue);
      await future;
      expect(container.read(authControllerProvider).isDeletingAccount, isFalse);
    });
  });
}
