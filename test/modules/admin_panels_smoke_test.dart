import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/modules/gyms/ui/panels/add_gym_theme_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/admin_home_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/admin_settings_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/gym_info_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/gym_setup_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/gym_themes_panel.dart';
import 'package:egoractive/modules/members/ui/panels/admin_member_list_panel.dart';
import 'package:egoractive/modules/members/ui/panels/member_info_panel.dart';
import 'package:egoractive/modules/members/ui/panels/new_membership_package_panel.dart';
import 'package:egoractive/modules/members/ui/panels/new_membership_payment_panel.dart';
import 'package:egoractive/modules/packages/ui/panels/edit_studio_package_panel.dart';
import 'package:egoractive/modules/packages/ui/panels/studio_packages_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/admin_trainer_management_panel.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.build(colors: AppColorScheme.defaultScheme(), typography: AppTypography.standard()),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final panels = <String, Widget>{
    'GymSetupPanel': const GymSetupPanel(),
    'AdminHomePanel': const AdminHomePanel(),
    'GymInfoPanel': const GymInfoPanel(),
    'GymThemesPanel': const GymThemesPanel(),
    'AddGymThemePanel': const AddGymThemePanel(),
    'AdminTrainerManagementPanel': const AdminTrainerManagementPanel(),
    'AdminMemberListPanel': const AdminMemberListPanel(),
    'MemberInfoPanel (new)': const MemberInfoPanel(),
    'NewMembershipPackagePanel': const NewMembershipPackagePanel(),
    'NewMembershipPaymentPanel': const NewMembershipPaymentPanel(),
    'StudioPackagesPanel': const StudioPackagesPanel(),
    'EditStudioPackagePanel (new)': const EditStudioPackagePanel(),
    'AdminSettingsPanel': const AdminSettingsPanel(),
  };

  for (final entry in panels.entries) {
    testWidgets('${entry.key} renders without overflow or render errors', (tester) async {
      await tester.pumpWidget(_wrap(entry.value));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${entry.key} threw during initial render');
    });

    testWidgets('${entry.key} renders without overflow on iPhone SE-sized screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(entry.value));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '${entry.key} threw on a small screen');
    });
  }

  testWidgets('AdminMemberListPanel filter chips render without overflow', (tester) async {
    await tester.pumpWidget(_wrap(const AdminMemberListPanel()));
    await tester.pump();
    await tester.tap(find.text('Bitiyor').first);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AddGymThemePanel palette selection renders without overflow', (tester) async {
    await tester.pumpWidget(_wrap(const AddGymThemePanel()));
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
