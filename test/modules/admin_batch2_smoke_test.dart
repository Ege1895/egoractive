import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/remote_config/remote_config_service.dart';
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
import 'package:egoractive/modules/members/controller/admin_member_detail_controller.dart';
import 'package:egoractive/modules/members/domain/admin_member_detail.dart';
import 'package:egoractive/modules/members/ui/panels/admin_member_detail_panel.dart';
import 'package:egoractive/modules/notifications/ui/panels/send_notification_panel.dart';
import 'package:egoractive/modules/reports/ui/panels/admin_dashboard_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/admin_calendar_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/admin_session_management_panel.dart';
import 'package:egoractive/modules/trainers/domain/trainer_member_detail.dart';
import 'package:egoractive/modules/trainers/domain/trainer_metric.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.build(
        colors: AppColorScheme.defaultScheme(),
        typography: AppTypography.standard(),
      ),
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
      home: Scaffold(body: child),
    ),
  );
}

/// AdminMemberDetailController artık `users/{memberId}` dokümanını gerçek
/// zamanlı Firestore'dan okuyor (bkz. #100) — bu smoke test'lerde Firebase
/// başlatılmadığı için stream hiç çözülmez ve panel sonsuza kadar loading
/// state'inde kalır. Testler burada gerçek veriye değil render davranışına
/// baktığı için controller'ı sabit bir örnek değerle override ediyoruz.
const _fixedMemberDetail = AdminMemberDetail(
  id: 'ayse-yilmaz',
  initials: 'AY',
  name: 'Ayşe Yılmaz',
  phone: '0532 418 76 05',
  trainerName: 'Berk Aydın',
  remainingSessions: 6,
  makeupSessions: 2,
  packageEndDate: '30.9.2026',
  paymentTotalTl: 14400,
  paymentPaidTl: 9600,
  lastPaymentDate: '8 Ağustos',
  history: [
    SessionHistoryEntry(
      date: '30 Tem',
      type: 'Birebir · 18:30',
      stateLabel: 'Tamamlandı',
      isPositive: true,
    ),
  ],
  seriesByMetric: {
    TrainerMetric.kilo: TrainerMetricSeries(
      metric: TrainerMetric.kilo,
      values: [68.4, 67.1],
      months: ['Tem', 'Ağu'],
    ),
    TrainerMetric.belCevresi: TrainerMetricSeries(
      metric: TrainerMetric.belCevresi,
      values: [82, 80],
      months: ['Tem', 'Ağu'],
    ),
    TrainerMetric.yagOrani: TrainerMetricSeries(
      metric: TrainerMetric.yagOrani,
      values: [27.5, 26.1],
      months: ['Tem', 'Ağu'],
    ),
  },
);

class _FixedAdminMemberDetailController extends AdminMemberDetailController {
  @override
  AdminMemberDetail build(String memberId) => _fixedMemberDetail;
}

/// Gerçek Firebase Remote Config'e dokunmayan sahte servis — bu dosya panel
/// geçişlerini test eder, Firebase entegrasyonunu değil. `rcTextProvider`,
/// Firebase.initializeApp hiç çağrılmamış test ortamında `getString`'i
/// yakalayıp boş döner (bkz. remote_config_service.dart); testin beklediği
/// sabit metinleri döndürmek için `_tr`/`_en` eki fark etmeksizin taban
/// anahtara göre çözüyoruz.
class _FakeRemoteConfigService extends RemoteConfigService {
  const _FakeRemoteConfigService();

  static const _values = <String, String>{
    'lbl_common_tamamlandi': 'Tamamlandı',
  };

  @override
  String getString(String key) =>
      _values[key.replaceFirst(RegExp(r'_(tr|en)$'), '')] ?? '';
}

final _sessionManagementOverrides = [
  remoteConfigServiceProvider.overrideWithValue(
    const _FakeRemoteConfigService(),
  ),
];

final _adminMemberDetailOverrides = [
  adminMemberDetailControllerProvider(
    'ayse-yilmaz',
  ).overrideWith(_FixedAdminMemberDetailController.new),
];

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
    'AdminMemberDetailPanel': const AdminMemberDetailPanel(
      memberId: 'ayse-yilmaz',
    ),
    'AdminDashboardPanel': const AdminDashboardPanel(),
  };

  for (final entry in panels.entries) {
    testWidgets('${entry.key} renders without overflow or render errors', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(entry.value));
      // GymRulesEditorPanel'in Quill araç çubuğu ilk frame'de sıfır süreli bir
      // Timer.run() zamanlayıcısı kuruyor (kaydırma okları için) — sahte saati
      // ilerletmeden pump() bunu temizlemiyor.
      await tester.pump(const Duration(milliseconds: 10));
      expect(
        tester.takeException(),
        isNull,
        reason: '${entry.key} threw during initial render',
      );
    });

    testWidgets(
      '${entry.key} renders without overflow on iPhone SE-sized screens',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 667));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(_wrap(entry.value));
        await tester.pump(const Duration(milliseconds: 10));
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} threw on a small screen',
        );
      },
    );
  }

  testWidgets(
    'AdminCalendarPanel month view responds to day taps without overflow',
    (tester) async {
      await tester.pumpWidget(_wrap(const AdminCalendarPanel()));
      await tester.pump();
      await tester.tap(find.text('4').first);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'AdminSessionManagementPanel filter chips render without overflow',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          const AdminSessionManagementPanel(),
          overrides: _sessionManagementOverrides,
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Tamamlandı').first);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SendNotificationPanel target switch renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const SendNotificationPanel()));
    await tester.pump();
    await tester.tap(find.text('Seçili üyeler'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('AdminMemberDetailPanel metric picker renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AdminMemberDetailPanel(memberId: 'ayse-yilmaz'),
        overrides: _adminMemberDetailOverrides,
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Kilo'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
