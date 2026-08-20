import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/auth/controller/auth_controller.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';

/// Gerçek Firebase çağrısı (F1-10) yapmayan sahte repository — bu dosya
/// controller'ın state geçişlerini test eder, Firebase entegrasyonunu değil.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login(String phoneDigits) =>
      Future<void>.delayed(const Duration(seconds: 2));

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

    test(
      'requestLogin is a no-op until the phone number is complete',
      () async {
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(authControllerProvider.notifier);

        await notifier.requestLogin();
        expect(
          container.read(authControllerProvider).isRequestingLogin,
          isFalse,
        );
      },
    );

    test(
      'requestLogin toggles isRequestingLogin around the mock call',
      () async {
        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
          ],
        );
        addTearDown(container.dispose);
        final notifier = container.read(authControllerProvider.notifier);

        notifier.setPhoneDigits('5324187605');

        final future = notifier.requestLogin();
        expect(
          container.read(authControllerProvider).isRequestingLogin,
          isTrue,
        );
        await future;
        expect(
          container.read(authControllerProvider).isRequestingLogin,
          isFalse,
        );
      },
    );

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
