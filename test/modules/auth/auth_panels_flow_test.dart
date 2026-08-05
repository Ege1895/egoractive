import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/main.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';

/// Gerçek Firebase çağrısı (F1-10) yapmayan sahte repository — bu dosya
/// panel geçişlerini test eder, Firebase entegrasyonunu değil.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login(String phoneDigits) => Future<void>.delayed(const Duration(seconds: 2));

  @override
  Future<void> deleteAccount() => Future<void>.delayed(const Duration(seconds: 2));
}

void main() {
  testWidgets(
    'Splash auto-transitions to phone login, native keyboard input fills the '
    'number, login pushes the waiting screen, and cancel returns while still loading',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository())],
          child: const EgoractiveApp(),
        ),
      );
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

      // Fake login isteği (2sn) hâlâ sürerken iptal edilebiliyor.
      await tester.tap(find.text('İptal'));
      await tester.pumpAndSettle();
      expect(find.text('Telefonunla giriş yap'), findsOneWidget);

      // Fake isteğin zamanlayıcısı hâlâ ayakta — testin "pending timer"
      // hatasıyla bitmemesi için tamamlanmasını bekle.
      await tester.pump(const Duration(seconds: 2));
    },
  );

  testWidgets(
    'Successful mock login shows no error and leaves waiting-for-role state to the '
    'global router (F1-11, only exercised against real Firebase — see app_router_test.dart)',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository())],
          child: const EgoractiveApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '5324187605');
      await tester.pump();
      await tester.tap(find.text('Giriş yap'));
      await tester.pump();
      expect(find.text('Seni tanıyoruz…'), findsOneWidget);

      // Fake repository başarıyla "giriş yapar" ama gerçek bir Firebase Auth
      // oturumu açmaz — bu yüzden main.dart'taki rol dinleyicisi tetiklenmez
      // ve panel hata göstermeden bekleme ekranında kalır (F1-11'in asıl
      // yönlendirme mantığı app_router_test.dart'ta Firebase'siz test ediliyor).
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(find.text('Seni tanıyoruz…'), findsOneWidget);
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
