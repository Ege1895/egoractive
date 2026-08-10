import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/modules/events/ui/panels/admin_events_panel.dart';
import 'package:egoractive/modules/events/ui/panels/create_event_panel.dart';
import 'package:egoractive/modules/expenses/ui/panels/add_expense_panel.dart';
import 'package:egoractive/modules/expenses/ui/panels/admin_expenses_panel.dart';
import 'package:egoractive/modules/feedback/ui/panels/admin_feedback_list_panel.dart';
import 'package:egoractive/modules/group_sessions/ui/panels/admin_group_sessions_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/admin_permissions_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/gym_rules_editor_panel.dart';
import 'package:egoractive/modules/gyms/ui/panels/gym_rules_view_panel.dart';
import 'package:egoractive/modules/members/ui/panels/admin_member_detail_panel.dart';
import 'package:egoractive/modules/notifications/ui/panels/send_notification_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/admin_calendar_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/admin_session_management_panel.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.build(colors: AppColorScheme.defaultScheme(), typography: AppTypography.standard()),
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final panels = <String, Widget>{
    'AdminCalendarPanel': const AdminCalendarPanel(),
    'AdminSessionManagementPanel': const AdminSessionManagementPanel(),
    'AdminGroupSessionsPanel': const AdminGroupSessionsPanel(),
    'AdminEventsPanel': const AdminEventsPanel(),
    'CreateEventPanel': const CreateEventPanel(),
    'AdminExpensesPanel': const AdminExpensesPanel(),
    'AddExpensePanel': const AddExpensePanel(),
    'GymRulesViewPanel': const GymRulesViewPanel(),
    'GymRulesEditorPanel': const GymRulesEditorPanel(),
    'AdminPermissionsPanel': const AdminPermissionsPanel(),
    'AdminFeedbackListPanel': const AdminFeedbackListPanel(),
    'SendNotificationPanel': const SendNotificationPanel(),
    'AdminMemberDetailPanel': const AdminMemberDetailPanel(memberId: 'ayse-yilmaz'),
  };

  for (final entry in panels.entries) {
    testWidgets('${entry.key} renders without overflow or render errors', (tester) async {
      await tester.pumpWidget(_wrap(entry.value));
      // GymRulesEditorPanel'in Quill araç çubuğu ilk frame'de sıfır süreli bir
      // Timer.run() zamanlayıcısı kuruyor (kaydırma okları için) — sahte saati
      // ilerletmeden pump() bunu temizlemiyor.
      await tester.pump(const Duration(milliseconds: 10));
      expect(tester.takeException(), isNull, reason: '${entry.key} threw during initial render');
    });

    testWidgets('${entry.key} renders without overflow on iPhone SE-sized screens', (tester) async {
      await tester.binding.setSurfaceSize(const Size(375, 667));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_wrap(entry.value));
      await tester.pump(const Duration(milliseconds: 10));
      expect(tester.takeException(), isNull, reason: '${entry.key} threw on a small screen');
    });
  }

  testWidgets('AdminCalendarPanel month view responds to day taps without overflow', (tester) async {
    await tester.pumpWidget(_wrap(const AdminCalendarPanel()));
    await tester.pump();
    await tester.tap(find.text('4').first);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdminSessionManagementPanel filter chips render without overflow', (tester) async {
    await tester.pumpWidget(_wrap(const AdminSessionManagementPanel()));
    await tester.pump();
    await tester.tap(find.text('Tamamlandı').first);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('SendNotificationPanel target switch renders without overflow', (tester) async {
    await tester.pumpWidget(_wrap(const SendNotificationPanel()));
    await tester.pump();
    await tester.tap(find.text('Tek üye'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdminMemberDetailPanel metric picker renders without overflow', (tester) async {
    await tester.pumpWidget(_wrap(const AdminMemberDetailPanel(memberId: 'ayse-yilmaz')));
    await tester.pump();
    await tester.tap(find.text('Kilo'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
