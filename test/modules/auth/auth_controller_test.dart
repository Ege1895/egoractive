import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/auth/controller/auth_controller.dart';

void main() {
  group('AuthController', () {
    test('appendDigit stops at 10 digits, removeLastDigit trims one', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      for (final d in '5324187605123'.split('')) {
        notifier.appendDigit(d);
      }
      expect(container.read(authControllerProvider).phoneDigits, '5324187605');
      expect(container.read(authControllerProvider).isPhoneComplete, isTrue);

      notifier.removeLastDigit();
      expect(container.read(authControllerProvider).phoneDigits, '532418760');
      expect(container.read(authControllerProvider).isPhoneComplete, isFalse);
    });

    test('removeLastDigit on empty digits is a no-op', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      notifier.removeLastDigit();
      expect(container.read(authControllerProvider).phoneDigits, '');
    });

    test('requestLogin is a no-op until the phone number is complete', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.requestLogin();
      expect(container.read(authControllerProvider).isRequestingLogin, isFalse);
    });

    test('requestLogin toggles isRequestingLogin around the mock call', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      for (final d in '5324187605'.split('')) {
        notifier.appendDigit(d);
      }

      final future = notifier.requestLogin();
      expect(container.read(authControllerProvider).isRequestingLogin, isTrue);
      await future;
      expect(container.read(authControllerProvider).isRequestingLogin, isFalse);
    });

    test('deleteAccount requires acknowledgement first', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.deleteAccount();
      expect(container.read(authControllerProvider).isDeletingAccount, isFalse);

      notifier.toggleDeleteAcknowledged();
      expect(container.read(authControllerProvider).deleteAccountAcknowledged, isTrue);

      final future = notifier.deleteAccount();
      expect(container.read(authControllerProvider).isDeletingAccount, isTrue);
      await future;
      expect(container.read(authControllerProvider).isDeletingAccount, isFalse);
    });
  });
}
