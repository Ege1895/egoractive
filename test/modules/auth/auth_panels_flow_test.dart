import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/main.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';

/// Gerçek Firebase çağrısı (F1-10) yapmayan sahte repository — bu dosya
/// panel geçişlerini test eder, Firebase entegrasyonunu değil.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> login(String phoneDigits) =>
      Future<void>.delayed(const Duration(seconds: 2));

  @override
  Future<void> deleteAccount() =>
      Future<void>.delayed(const Duration(seconds: 2));

  @override
  Future<void> signOut() async {}
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
    'lbl_auth_splash_title': 'Egoractive',
    'lbl_auth_onboarding_role_title': 'Hoş geldin',
    'lbl_auth_onboarding_role_member_title': 'Üyeyim',
    'lbl_auth_onboarding_role_go_to_login_button': 'Girişe geç',
    'lbl_auth_phone_login_title': 'Telefonunla giriş yap',
    'lbl_auth_login_button': 'Giriş yap',
    'lbl_auth_login_waiting_heading': 'Seni tanıyoruz…',
    'lbl_auth_login_waiting_body': '+90 {phone} numarası stüdyoda aranıyor.',
    'lbl_auth_login_waiting_cancel_button': 'İptal',
  };

  @override
  String getString(String key) =>
      _values[key.replaceFirst(RegExp(r'_(tr|en)$'), '')] ?? '';
}

/// Splash'ın mock oturum kontrolü süresi geçip [OnboardingRolePanel]'e
/// düşmesini bekler, "Üyeyim"i seçip Telefonla Giriş ekranına geçer.
Future<void> _navigateToPhoneLogin(WidgetTester tester) async {
  await tester.pump();
  expect(find.text('Egoractive'), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 1700));
  await tester.pumpAndSettle();
  expect(find.text('Hoş geldin'), findsOneWidget);

  await tester.tap(find.text('Üyeyim'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Girişe geç'));
  await tester.pumpAndSettle();
  expect(find.text('Telefonunla giriş yap'), findsOneWidget);
}

void main() {
  testWidgets(
    'Splash auto-transitions to onboarding role picker, "Üyeyim" leads to phone '
    'login, native keyboard input fills the number, login pushes the waiting '
    'screen, and cancel returns while still loading',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
            remoteConfigServiceProvider.overrideWithValue(
              const _FakeRemoteConfigService(),
            ),
          ],
          child: const EgoractiveApp(),
        ),
      );
      await _navigateToPhoneLogin(tester);

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
      expect(
        find.text('+90 532 418 76 05 numarası stüdyoda aranıyor.'),
        findsOneWidget,
      );

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
          overrides: [
            authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
            remoteConfigServiceProvider.overrideWithValue(
              const _FakeRemoteConfigService(),
            ),
          ],
          child: const EgoractiveApp(),
        ),
      );
      await _navigateToPhoneLogin(tester);

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

  testWidgets('Splash cannot be reached again via back after replaceRoot', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          remoteConfigServiceProvider.overrideWithValue(
            const _FakeRemoteConfigService(),
          ),
        ],
        child: const EgoractiveApp(),
      ),
    );
    await _navigateToPhoneLogin(tester);

    // Sistem geri tuşu, PhoneLoginPanel'i pop edip bir önceki panele
    // (OnboardingRolePanel) döner — replaceRoot ile değiştirilen Splash'a
    // asla geri dönülemez.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Hoş geldin'), findsOneWidget);
    expect(find.text('Egoractive'), findsNothing);
  });
}
