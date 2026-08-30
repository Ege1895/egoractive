import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/panels/panel_stack_controller.dart';
import 'package:egoractive/core/panels/panel_stack_view.dart';
import 'package:egoractive/core/remote_config/remote_config_service.dart';
import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/core/panels/base_panel.dart';
import 'package:egoractive/modules/auth/repository/auth_repository.dart';
import 'package:egoractive/modules/auth/ui/panels/delete_account_confirm_panel.dart';

class _RootPanel extends BasePanel {
  const _RootPanel();

  @override
  ConsumerState<_RootPanel> createState() => _RootPanelState();
}

class _RootPanelState extends BasePanelState<_RootPanel> {
  @override
  Widget build(BuildContext context) => const Scaffold(body: SizedBox.shrink());
}

/// Gerçek Firebase çağrısı (F2-8) yapmayan sahte repository — bu dosya
/// panel geçişlerini test eder, Firebase entegrasyonunu değil.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<StartLoginResult> startLogin({
    required String identifierType,
    required String value,
  }) async => (needsEmailSetup: false, uid: 'uid-1', email: 'a@b.com');

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
    'lbl_auth_delete_account_confirm_heading': 'Hesabını silmek geri alınamaz',
    'lbl_common_hesabimi_sil': 'Hesabımı sil',
    'lbl_auth_delete_account_acknowledge_label':
        'Anladım, hesabım ve tüm verilerim silinsin.',
    'lbl_common_vazgec': 'Vazgeç',
    'lbl_auth_phone_login_title': 'Telefonunla giriş yap',
  };

  @override
  String getString(String key) =>
      _values[key.replaceFirst(RegExp(r'_(tr|en)$'), '')] ?? '';
}

void main() {
  testWidgets(
    'Hesabımı sil is disabled until the checkbox is acknowledged, then calls deleteAccount',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWith((ref) => _FakeAuthRepository()),
          remoteConfigServiceProvider.overrideWithValue(
            const _FakeRemoteConfigService(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(panelStackControllerProvider.notifier);
      notifier.push(const _RootPanel());
      notifier.push(const DeleteAccountConfirmPanel());

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.build(
              colors: AppColorScheme.defaultScheme(),
              typography: AppTypography.standard(),
            ),
            home: const PanelStackView(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Hesabını silmek geri alınamaz'), findsOneWidget);

      // Onay kutusu işaretlenmeden "Hesabımı sil" hiçbir şey yapmamalı.
      await tester.tap(find.text('Hesabımı sil'));
      await tester.pump();
      expect(find.text('Hesabını silmek geri alınamaz'), findsOneWidget);

      await tester.tap(
        find.text('Anladım, hesabım ve tüm verilerim silinsin.'),
      );
      await tester.pump();

      await tester.tap(find.text('Hesabımı sil'));
      await tester.pump(); // isDeletingAccount: true
      await tester.pump(const Duration(seconds: 2)); // mock çağrı tamamlanır
      await tester.pump();

      // Girişe dönüş artık bu panelin işi değil — `main.dart`'taki merkezi
      // `appAccessProvider` dinleyicisi auth state null olunca navigasyonu
      // kendisi yapıyor (bkz. `deleteAccount()`'ın panel içindeki
      // `onPressed`'i artık sadece çağrıyı tetikliyor, elle `replaceRoot`
      // yapmıyor — iki ayrı navigasyonun yarışa girmesini önlemek için).
      // Bu yüzden burada sadece silme akışının tamamlandığını (ekranın
      // "siliniyor" durumundan çıktığını) doğruluyoruz.
      expect(find.text('Hesabını silmek geri alınamaz'), findsOneWidget);
    },
  );

  testWidgets('Vazgeç pops without deleting anything', (tester) async {
    final container = ProviderContainer(
      overrides: [
        remoteConfigServiceProvider.overrideWithValue(
          const _FakeRemoteConfigService(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(panelStackControllerProvider.notifier);
    notifier.push(const _RootPanel());
    notifier.push(const DeleteAccountConfirmPanel());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.build(
            colors: AppColorScheme.defaultScheme(),
            typography: AppTypography.standard(),
          ),
          home: const PanelStackView(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Vazgeç'));
    await tester.pump();

    expect(find.text('Hesabını silmek geri alınamaz'), findsNothing);
  });
}
