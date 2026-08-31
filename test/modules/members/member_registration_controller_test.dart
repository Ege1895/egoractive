import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/modules/members/controller/member_registration_controller.dart';
import 'package:egoractive/modules/members/controller/new_member_controller.dart';

void main() {
  group('MemberRegistrationController validation', () {
    test(
      'fails without touching Firebase when name/phone are incomplete',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(
          memberRegistrationControllerProvider.notifier,
        );

        // Varsayılan NewMemberForm boş isim + boş telefonla başlar.
        final success = await notifier.submit();

        expect(success, isFalse);
        // Genel bir banner yerine hangi alanın eksik olduğu ayrı ayrı
        // gösteriliyor (bkz. task #90).
        expect(
          container.read(memberRegistrationControllerProvider).nameError,
          contains('Ad ve soyad'),
        );
        expect(
          container.read(memberRegistrationControllerProvider).phoneError,
          isNotNull,
        );
        expect(
          container.read(memberRegistrationControllerProvider).isSubmitting,
          isFalse,
        );
      },
    );

    test(
      'fails the same way when only the phone number is incomplete',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        container
            .read(newMemberControllerProvider.notifier)
            .updateFirstName('Ayşe');
        container
            .read(newMemberControllerProvider.notifier)
            .updateLastName('Yılmaz');
        container
            .read(newMemberControllerProvider.notifier)
            .updatePhone('+90123', isValid: false);
        final notifier = container.read(
          memberRegistrationControllerProvider.notifier,
        );

        final success = await notifier.submit();

        expect(success, isFalse);
        expect(
          container.read(memberRegistrationControllerProvider).phoneError,
          contains('Geçerli bir telefon'),
        );
        expect(
          container.read(memberRegistrationControllerProvider).nameError,
          isNull,
        );
      },
    );
  });
}
