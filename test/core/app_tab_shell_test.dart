import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/panels/shell/admin_shell_panel.dart';
import 'package:egoractive/core/panels/shell/app_tab_shell.dart';
import 'package:egoractive/core/panels/shell/member_shell_panel.dart';
import 'package:egoractive/core/panels/shell/trainer_shell_panel.dart';
import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';

/// Gerçek Firebase Remote Config'e dokunmayan sahte servis — bu dosya panel
/// geçişlerini test eder, Firebase entegrasyonunu değil. `rcTextProvider`,
/// Firebase.initializeApp hiç çağrılmamış test ortamında `getString`'i
/// yakalayıp boş döner (bkz. remote_config_service.dart); testin beklediği
/// sabit metinleri döndürmek için `_tr`/`_en` eki fark etmeksizin taban
/// anahtara göre çözüyoruz.
class _FakeRemoteConfigService extends RemoteConfigService {
  const _FakeRemoteConfigService();

  static const _values = <String, String>{
    'lbl_sessions_list_title': 'Derslerim',
    'lbl_trainers_calendar_title': 'Takvimim',
    'lbl_expenses_list_title': 'Giderler',
    // Alt navigasyon etiketleri de artık RC'den geliyor (sabit Türkçe
    // metinlerdi, uygulama İngilizce'yken bile Türkçe kalıyorlardı).
    'lbl_shell_tab_home': 'Ana Sayfa',
    'lbl_shell_tab_profile': 'Profil',
    'lbl_shell_member_tab_derslerim': 'Derslerim',
    'lbl_shell_member_tab_olcumlerim': 'Ölçümlerim',
    'lbl_shell_member_tab_kesfet': 'Keşfet',
    'lbl_shell_trainer_tab_takvimim': 'Takvimim',
    'lbl_shell_trainer_tab_uyelerim': 'Üyelerim',
    'lbl_shell_admin_tab_uyeler': 'Üyeler',
    'lbl_shell_admin_tab_seanslar': 'Seanslar',
    'lbl_shell_admin_tab_finans': 'Finans',
    'lbl_shell_admin_tab_ayarlar': 'Ayarlar',
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
      home: child,
    ),
  );
}

void main() {
  testWidgets('AppTabShell switches the visible tab on tap', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AppTabShell(
          items: [
            AppTabItem(
              icon: Icons.home,
              label: 'Bir',
              builder: (_) => const Text('İçerik 1'),
            ),
            AppTabItem(
              icon: Icons.star,
              label: 'İki',
              builder: (_) => const Text('İçerik 2'),
            ),
          ],
        ),
      ),
    );

    expect(find.text('İçerik 1'), findsOneWidget);
    expect(find.text('İçerik 2'), findsNothing);

    await tester.tap(find.text('İki'));
    await tester.pumpAndSettle();

    expect(find.text('İçerik 1'), findsNothing);
    expect(find.text('İçerik 2'), findsOneWidget);
  });

  for (final entry in {
    'Üye': (const MemberShellPanel(), 'Derslerim'),
    'Antrenör': (const TrainerShellPanel(), 'Takvimim'),
  }.entries) {
    testWidgets(
      '${entry.key} shell renders 5 tabs and can switch to "${entry.value.$2}"',
      (tester) async {
        await tester.pumpWidget(_wrap(entry.value.$1));
        await tester.pumpAndSettle();

        expect(
          find.byType(BottomNavigationBar),
          findsNothing,
        ); // özel tab bar kullanıyoruz
        expect(find.text(entry.value.$2), findsOneWidget);

        await tester.tap(find.text(entry.value.$2));
        await tester.pumpAndSettle();

        // Sekme etiketi (alt bar) + placeholder başlığı aynı metni taşır.
        expect(find.text(entry.value.$2), findsNWidgets(2));
      },
    );
  }

  testWidgets('Admin shell renders 5 tabs and can switch to "Finans"', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AdminShellPanel()));
    await tester.pumpAndSettle();

    expect(
      find.byType(BottomNavigationBar),
      findsNothing,
    ); // özel tab bar kullanıyoruz
    expect(find.text('Finans'), findsOneWidget);

    await tester.tap(find.text('Finans'));
    await tester.pumpAndSettle();

    // Admin sekmelerinde tab etiketi ile panel başlığı tasarım gereği farklı
    // (ör. "Finans" sekmesi "Giderler" ekranını açar) — gerçek panel
    // içeriğinin göründüğünü doğrula.
    expect(find.text('Finans'), findsOneWidget);
    expect(find.text('Giderler'), findsOneWidget);
  });
}
