import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/theme/theme_controller.dart';
import 'package:egoractive/modules/gyms/controller/gym_profile_controller.dart';

void main() {
  // `GymProfileController` autoDispose'dur ve `activeGymIdProvider`'a
  // bağlıdır — gerçek Firebase olmadan test edebilmek için burada `null`
  // (aktif salon yok, tam da `GymSetupPanel`'in yeni salon kurulumu
  // senaryosu) ile override ediyoruz.
  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [activeGymIdProvider.overrideWith((ref) async => null)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'without a live watcher, typed data is lost once the provider is disposed '
    '(this is the bug reported for GymSetupPanel — fields showed "required" '
    'errors even though the user had typed values)',
    () async {
      final container = buildContainer();

      // `GymSetupPanel` only ever did `ref.read(...notifier)` — never
      // `ref.watch(gymProfileControllerProvider)` — so nothing kept the
      // autoDispose provider alive between calls.
      container
          .read(gymProfileControllerProvider.notifier)
          .updateName('Texas Gym');

      // Let the event loop run the scheduled autoDispose teardown.
      await Future<void>.delayed(const Duration(milliseconds: 5));

      // A fresh read rebuilds the provider from scratch — the typed name is
      // gone.
      expect(container.read(gymProfileControllerProvider).name, isEmpty);
    },
  );

  test(
    'holding a subscription (as GymSetupPanel now does via ref.watch) keeps '
    'typed data alive across the same window',
    () async {
      final container = buildContainer();

      // Mirrors `ref.watch(gymProfileControllerProvider)` in the panel —
      // this is the actual fix.
      final subscription = container.listen(
        gymProfileControllerProvider,
        (previous, next) {},
      );
      addTearDown(subscription.close);

      container
          .read(gymProfileControllerProvider.notifier)
          .updateName('Texas Gym');
      container.read(gymProfileControllerProvider.notifier).updateCity('Austin');
      container
          .read(gymProfileControllerProvider.notifier)
          .updateAddress('Texas');

      await Future<void>.delayed(const Duration(milliseconds: 5));

      final profile = container.read(gymProfileControllerProvider);
      expect(profile.name, 'Texas Gym');
      expect(profile.city, 'Austin');
      expect(profile.address, 'Texas');
    },
  );
}
