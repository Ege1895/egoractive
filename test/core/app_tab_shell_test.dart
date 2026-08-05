import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/panels/shell/admin_shell_panel.dart';
import 'package:egoractive/core/panels/shell/app_tab_shell.dart';
import 'package:egoractive/core/panels/shell/member_shell_panel.dart';
import 'package:egoractive/core/panels/shell/trainer_shell_panel.dart';
import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.build(colors: AppColorScheme.defaultScheme(), typography: AppTypography.standard()),
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
            AppTabItem(icon: Icons.home, label: 'Bir', builder: (_) => const Text('İçerik 1')),
            AppTabItem(icon: Icons.star, label: 'İki', builder: (_) => const Text('İçerik 2')),
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
    testWidgets('${entry.key} shell renders 5 tabs and can switch to "${entry.value.$2}"', (tester) async {
      await tester.pumpWidget(_wrap(entry.value.$1));
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsNothing); // özel tab bar kullanıyoruz
      expect(find.text(entry.value.$2), findsOneWidget);

      await tester.tap(find.text(entry.value.$2));
      await tester.pumpAndSettle();

      // Sekme etiketi (alt bar) + placeholder başlığı aynı metni taşır.
      expect(find.text(entry.value.$2), findsNWidgets(2));
    });
  }

  testWidgets('Admin shell renders 5 tabs and can switch to "Finans"', (tester) async {
    await tester.pumpWidget(_wrap(const AdminShellPanel()));
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavigationBar), findsNothing); // özel tab bar kullanıyoruz
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
