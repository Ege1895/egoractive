import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/modules/group_sessions/ui/panels/create_group_session_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/trainer_calendar_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/trainer_home_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/trainer_member_detail_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/trainer_members_list_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/trainer_profile_panel.dart';
import 'package:egoractive/modules/trainers/ui/panels/trainer_report_panel.dart';

Widget _wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.build(
        colors: AppColorScheme.defaultScheme(),
        typography: AppTypography.standard(),
      ),
      home: Scaffold(body: child),
    ),
  );
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
    'lbl_trainers_calendar_month_toggle': 'Ay',
    'lbl_trainers_members_filter_expiring': 'Paketi bitiyor',
  };

  @override
  String getString(String key) =>
      _values[key.replaceFirst(RegExp(r'_(tr|en)$'), '')] ?? '';
}

final _fakeRcOverrides = [
  remoteConfigServiceProvider.overrideWithValue(
    const _FakeRemoteConfigService(),
  ),
];

void main() {
  final panels = <String, Widget>{
    'TrainerHomePanel': const TrainerHomePanel(),
    'TrainerCalendarPanel': const TrainerCalendarPanel(),
    'TrainerMembersListPanel': const TrainerMembersListPanel(),
    'TrainerMemberDetailPanel': const TrainerMemberDetailPanel(
      memberId: 'ayse-yilmaz',
    ),
    'TrainerReportPanel': const TrainerReportPanel(),
    'TrainerProfilePanel': const TrainerProfilePanel(),
    'CreateGroupSessionPanel': const CreateGroupSessionPanel(),
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

  testWidgets('TrainerCalendarPanel month view renders without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const TrainerCalendarPanel(), overrides: _fakeRcOverrides),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('TrainerMembersListPanel filter chips render without overflow', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const TrainerMembersListPanel(), overrides: _fakeRcOverrides),
    );
    await tester.pump();
    await tester.tap(find.text('Paketi bitiyor'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
