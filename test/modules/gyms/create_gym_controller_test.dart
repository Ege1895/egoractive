import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/gyms/controller/create_gym_controller.dart';
import 'package:egoractive/modules/gyms/controller/gym_profile_controller.dart';

void main() {
  group('CreateGymController validation', () {
    test('does not require a logo — validation passes through to the (network) submit step', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(createGymControllerProvider.notifier);

      // Mock profil varsayılan olarak tüm alanları dolu getirir ve logo hiç
      // seçilmedi — validasyon artık logo'yu zorunlu tutmadığı için istek
      // Firebase'e kadar ilerliyor ve orada (test ortamında Firebase
      // başlatılmadığı için) genel bağlantı hatasıyla başarısız oluyor —
      // "logo eksik" validasyon hatası artık hiç tetiklenmiyor.
      final gymId = await notifier.submit();

      expect(gymId, isNull);
      expect(container.read(createGymControllerProvider).errorMessage, isNot(contains('logo')));
      expect(container.read(createGymControllerProvider).isSubmitting, isFalse);
    });

    test('fails with a field-level error when a required field is blank', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(gymProfileControllerProvider.notifier).updateName('');
      final notifier = container.read(createGymControllerProvider.notifier);

      final gymId = await notifier.submit();

      expect(gymId, isNull);
      // Genel bir banner yerine hangi alanın eksik olduğu ayrı ayrı
      // gösteriliyor (bkz. task #89).
      expect(container.read(createGymControllerProvider).nameError, contains('Salon adı'));
      expect(container.read(createGymControllerProvider).errorMessage, isNull);
    });
  });
}
