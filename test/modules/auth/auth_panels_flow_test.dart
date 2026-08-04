import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/main.dart';

void main() {
  testWidgets(
    'Splash auto-transitions to phone login, native keyboard input fills the '
    'number, login pushes the waiting screen, and cancel returns',
    (tester) async {
      await tester.pumpWidget(const ProviderScope(child: EgoractiveApp()));
      await tester.pump();
      expect(find.text('Egoractive'), findsOneWidget);

      // Splash'ın mock oturum kontrolü süresi geçsin.
      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();
      expect(find.text('Telefonunla giriş yap'), findsOneWidget);

      // Giriş yap butonu numara tamamlanmadan disabled.
      final loginButtonFinder = find.text('Giriş yap');
      expect(loginButtonFinder, findsOneWidget);

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '5324187605');
      await tester.pump();
      expect(find.text('532 418 76 05'), findsOneWidget);

      await tester.tap(loginButtonFinder);
      // Bekleme ekranında sürekli dönen bir gösterge var, pumpAndSettle asla
      // durmaz — tek kare basıp geçişin gerçekleştiğini doğruluyoruz.
      await tester.pump();
      expect(find.text('Seni tanıyoruz…'), findsOneWidget);
      expect(find.text('+90 532 418 76 05 numarası stüdyoda aranıyor.'), findsOneWidget);

      // Mock login isteğinin (2sn) tamamlanmasını bekle, aksi halde test
      // "pending timer" hatasıyla bitiyor.
      await tester.pump(const Duration(seconds: 2));

      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();
      expect(find.text('Telefonunla giriş yap'), findsOneWidget);
    },
  );

  testWidgets('Splash cannot be reached again via back after replaceRoot', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: EgoractiveApp()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();
    expect(find.text('Telefonunla giriş yap'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Telefonunla giriş yap'), findsOneWidget);
    expect(find.text('Egoractive'), findsNothing);
  });
}
