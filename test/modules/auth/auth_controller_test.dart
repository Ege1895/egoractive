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
    test('setPhoneDigits strips non-digits and caps at 10 digits', () {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      notifier.setPhoneDigits('532 418 76 05 123');
      expect(container.read(authControllerProvider).phoneDigits, '5324187605');
      expect(container.read(authControllerProvider).isPhoneComplete, isTrue);

      notifier.setPhoneDigits('53241876');
      expect(container.read(authControllerProvider).phoneDigits, '53241876');
      expect(container.read(authControllerProvider).isPhoneComplete, isFalse);
    });

    test('setPhoneDigits with empty input clears the number', () {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      notifier.setPhoneDigits('5324187605');
      notifier.setPhoneDigits('');
      expect(container.read(authControllerProvider).phoneDigits, '');
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

      notifier.setPhoneDigits('5324187605');

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
