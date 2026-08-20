import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/modules/auth/ui/panels/profile_panel.dart';
import 'package:egoractive/modules/badges/ui/panels/badges_panel.dart';
import 'package:egoractive/modules/feedback/ui/panels/feedback_panel.dart';
import 'package:egoractive/modules/group_sessions/ui/panels/discover_panel.dart';
import 'package:egoractive/modules/measurements/ui/panels/measurements_panel.dart';
import 'package:egoractive/modules/packages/ui/panels/package_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/attendance_confirm_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/member_home_panel.dart';
import 'package:egoractive/modules/sessions/ui/panels/sessions_list_panel.dart';

/// Gerçek Firebase Remote Config'e dokunmayan sahte servis — bu dosya panel
/// geçişlerini test eder, Firebase entegrasyonunu değil. `rcTextProvider`,
/// Firebase.initializeApp hiç çağrılmamış test ortamında `getString`'i
/// yakalayıp boş döner (bkz. remote_config_service.dart); testin beklediği
/// sabit metinleri döndürmek için `_tr`/`_en` eki fark etmeksizin taban
/// anahtara göre çözüyoruz.
class _FakeRemoteConfigService extends RemoteConfigService {
  const _FakeRemoteConfigService();

  static const _values = <String, String>{
    'lbl_sessions_calendar_view_toggle': 'Takvim',
    'lbl_measurements_chart_toggle_label': 'Grafik',
    'lbl_group_sessions_discover_tab_events': 'Etkinlikler',
  };

  @override
  String getString(String key) =>
      _values[key.replaceFirst(RegExp(r'_(tr|en)$'), '')] ?? '';
}

Widget _wrap(Widget child) {
  return ProviderScope(
    overrides: [
      remoteConfigServiceProvider.overrideWithValue(
        const _FakeRemoteConfigService(),
      ),
    ],
    child: MaterialApp(
      theme: AppTheme.build(
        colors: AppColorScheme.defaultScheme(),
        typography: AppTypography.standard(),
      ),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  final panels = <String, Widget>{
    'MemberHomePanel': const MemberHomePanel(),
    'SessionsListPanel': const SessionsListPanel(),
    'AttendanceConfirmPanel': const AttendanceConfirmPanel(),
    'MeasurementsPanel': const MeasurementsPanel(),
    'PackagePanel': const PackagePanel(),
    'DiscoverPanel': const DiscoverPanel(),
    'BadgesPanel': const BadgesPanel(),
    'FeedbackPanel': const FeedbackPanel(),
    'ProfilePanel': const ProfilePanel(),
  };

  for (final entry in panels.entries) {
    testWidgets('${entry.key} renders without overflow or render errors', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(entry.value));
      await tester.pump();
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
        await tester.pump();
        expect(
          tester.takeException(),
          isNull,
          reason: '${entry.key} threw on a small screen',
        );
      },
    );
  }

  testWidgets('SessionsListPanel calendar view renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const SessionsListPanel()));
    await tester.pump();
    await tester.tap(find.text('Takvim'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('MeasurementsPanel chart view renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const MeasurementsPanel()));
    await tester.pump();
    await tester.tap(find.text('Grafik'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('DiscoverPanel events tab renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const DiscoverPanel()));
    await tester.pump();
    await tester.tap(find.text('Etkinlikler'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
