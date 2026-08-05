import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/gyms/controller/create_gym_controller.dart';
import 'package:egoractive/modules/gyms/controller/gym_profile_controller.dart';

void main() {
  group('CreateGymController validation', () {
    test('fails with a missing-logo message when no logo has been picked', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(createGymControllerProvider.notifier);

      // Mock profil varsayılan olarak tüm alanları dolu getirir — bu yüzden
      // Firebase'e hiç dokunmadan sadece "logo eksik" validasyonu tetiklenir.
      final gymId = await notifier.submit();

      expect(gymId, isNull);
      expect(container.read(createGymControllerProvider).errorMessage, contains('logo'));
      expect(container.read(createGymControllerProvider).isSubmitting, isFalse);
    });

    test('fails with an empty-fields message when a required field is blank', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gymProfileControllerProvider.notifier).updateName('');
      final notifier = container.read(createGymControllerProvider.notifier);

      final gymId = await notifier.submit();

      expect(gymId, isNull);
      expect(container.read(createGymControllerProvider).errorMessage, contains('tüm alanları'));
    });
  });
}
