import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/main.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';

/// Gerçek Firebase çağrısı yapmayan sahte repository — bu dosya panel
/// geçişlerini test eder, Firebase entegrasyonunu değil.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<StartLoginResult> startLogin({
    required String identifierType,
    required String value,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return (needsEmailSetup: false, uid: 'uid-1', email: 'a@b.com');
  }

  @override
  Future<void> verifyLoginOtp({required String uid, required String code}) =>
      Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> sendEmailSetupOtp({
    required String uid,
    required String email,
  }) => Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> verifyEmailSetupOtp({
    required String uid,
    required String code,
  }) => Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> sendEmailChangeOtp(String newEmail) =>
      Future<void>.delayed(const Duration(milliseconds: 1));

  @override
  Future<void> verifyEmailChangeOtp(String code) =>
      Future<void>.delayed(const Duration(milliseconds: 1));

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
    'lbl_auth_otp_title': 'Doğrulama kodu',
    'lbl_auth_otp_subtitle': 'Kod {email} adresine gönderildi.',
    'lbl_auth_otp_verify_button': 'Doğrula',
    'lbl_auth_otp_resend_button': 'Tekrar gönder',
    'lbl_auth_otp_resend_countdown_template': 'Tekrar gönder ({seconds}s)',
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
    'Splash auto-transitions to onboarding role picker, "Üyeyim" leads to '
    'phone login, native keyboard input fills the number, login shows a '
    'loading state on the button and then pushes the OTP screen; OTP screen '
    'back button returns to phone login with the number preserved',
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
      await tester.pump();
      // Fake startLogin (2sn) sürerken buton "Seni tanıyoruz…" durumuna geçer.
      expect(find.text('Seni tanıyoruz…'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Doğrulama kodu'), findsOneWidget);

      // OTP ekranının geri butonu telefon giriş ekranına döner, numara
      // (AuthController state'i, Visibility(maintainState:true) sayesinde
      // TextField'ın kendi local state'i de) korunmuş olur.
      await tester.tap(find.byIcon(Icons.chevron_left).first);
      await tester.pumpAndSettle();
      expect(find.text('Telefonunla giriş yap'), findsOneWidget);
      expect(find.text('532 418 76 05'), findsOneWidget);
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
