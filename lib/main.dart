import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/constants/ad_constants.dart';
import 'core/deep_links/app_deep_link_service.dart';
import 'core/locale/locale_controller.dart';
import 'core/locale/locale_prefs.dart';
import 'core/onboarding/onboarding_prefs.dart';
import 'core/panels/panel_stack_controller.dart';
import 'core/panels/panel_stack_view.dart';
import 'core/remote_config/remote_config_service.dart';
import 'core/router/app_access.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_color_scheme.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';
import 'modules/auth/ui/panels/email_setup_panel.dart';
import 'modules/auth/ui/panels/phone_login_panel.dart';
import 'modules/auth/ui/panels/splash_panel.dart';
import 'modules/notifications/service/push_notification_service.dart';
import 'modules/subscription/ui/panels/subscription_onboarding_panel.dart';

/// Widget ağacı dışından (bildirim servisi gibi) `PanelStackController`'a
/// erişebilmek için paylaşılan container — `UncontrolledProviderScope` bunu
/// widget ağacına da bağlıyor.
final _providerContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await const RemoteConfigService().init();
  await LocalePrefs.init();
  await OnboardingPrefs.init();
  unawaited(MobileAds.instance.initialize());
  if (debugTestDeviceIds.isNotEmpty) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: debugTestDeviceIds),
    );
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // Push bildirim kurulumu opsiyonel bir iyileştirme — burada oluşacak
  // herhangi bir hata (izin reddi, APNS gecikmesi vb.) runApp() çağrısını
  // asla engellememeli, yoksa uygulama açılışta beyaz ekranda takılı kalır.
  try {
    await PushNotificationService().init(_providerContainer);
  } on Exception catch (error) {
    debugPrint(
      'Push bildirim kurulumu başarısız oldu, uygulama yine de açılıyor: $error',
    );
  }
  try {
    await AppDeepLinkService().init(_providerContainer);
  } on Exception catch (error) {
    debugPrint(
      'Deep link kurulumu başarısız oldu, uygulama yine de açılıyor: $error',
    );
  }
  runApp(
    UncontrolledProviderScope(
      container: _providerContainer,
      child: const EgoractiveApp(),
    ),
  );
}

class EgoractiveApp extends ConsumerWidget {
  const EgoractiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors =
        ref.watch(themeControllerProvider).valueOrNull ??
        AppColorScheme.defaultScheme();
    final locale = ref.watch(localeControllerProvider);
    return MaterialApp(
      title: 'Egoractive',
      theme: AppTheme.build(
        colors: colors,
        typography: AppTypography.standard(),
      ),
      locale: Locale(locale),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends ConsumerStatefulWidget {
  const _AppRoot();

  @override
  ConsumerState<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends ConsumerState<_AppRoot> {
  /// `appAccessProvider` abonelikle ilgisiz bir gym alanı (ör. logo)
  /// değiştiğinde bile yeniden hesaplanıp aynı kararı tekrar yayınlayabilir
  /// (bkz. o dosyadaki yorum) — burada son uygulanan kararla karşılaştırıp
  /// gerçek bir değişiklik yoksa `replaceRoot`'u tekrar çağırmayız, yoksa
  /// ekran (ör. admin'in o an bulunduğu sekme/scroll konumu) gereksiz yere
  /// sıfırlanırdı.
  AppAccess? _lastAccess;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(panelStackControllerProvider.notifier).push(const SplashPanel());
    });
  }

  @override
  Widget build(BuildContext context) {
    final stack = ref.watch(panelStackControllerProvider);

    // Salon Abonelik ve Erişim Akışı — tek yönlendirme kaynağı, artık
    // `appAccessProvider` üzerinden (rol + salonun CANLI abonelik durumu).
    // Splash sadece marka gösterimi + basit bir fallback'tir; asıl karar
    // burada verilir. Bu, uygulama açıkken abonelik durumu değişirse (admin
    // abone olur/olmaz, antrenör/üyenin salonu askıya alınır) ekranın anında
    // tepki vermesini sağlar — eskisi gibi sadece giriş anında tek seferlik
    // kontrol değil.
    ref.listen(appAccessProvider, (previous, next) {
      debugPrint(
        '[appAccess] listener isLoading=${next.isLoading} hasError=${next.hasError} '
        'error=${next.error} value=${next.valueOrNull}',
      );
      next.whenData((access) {
        if (access == _lastAccess) return;
        _lastAccess = access;
        _applyAccess(access);
      });
    });

    if (stack.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return const PanelStackView();
  }

  /// `signedOut` → oturumu kapatıp girişe döner. `blocked` (antrenör/üye,
  /// salonu inaktifken) → oturumu kapatıp girişe, bilgilendirici bir mesajla
  /// döner — [PhoneLoginPanel.errorBanner]'ın gösterdiği metin zaten reason-
  /// agnostic olduğu için burada ayrıca metin üretmeye gerek yok, sadece
  /// [AuthController]'ın normal login denemesi başarısız olduğunda gösterdiği
  /// mesajla tutarlı kalsın diye aynı Remote Config metnini okuyoruz.
  /// `subscriptionOnboarding` (admin, salonu inaktifken) → zorunlu abonelik
  /// ekranı. `ready` → role uygun shell.
  Future<void> _applyAccess(AppAccess access) async {
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    switch (access.kind) {
      case AppAccessKind.signedOut:
        if (FirebaseAuth.instance.currentUser != null) {
          await FirebaseAuth.instance.signOut();
        }
        panelStack.replaceRoot(const PhoneLoginPanel());
      case AppAccessKind.emailSetupRequired:
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) {
          panelStack.replaceRoot(const PhoneLoginPanel());
          return;
        }
        panelStack.replaceRoot(EmailSetupPanel(uid: uid));
      case AppAccessKind.blocked:
        final message = ref
            .read(remoteConfigServiceProvider)
            .getText(
              RemoteConfigKeys.authLoginErrorSubscriptionInactive,
              ref.read(localeControllerProvider),
            );
        await FirebaseAuth.instance.signOut();
        panelStack.replaceRoot(PhoneLoginPanel(errorBanner: message));
      case AppAccessKind.subscriptionOnboarding:
        panelStack.replaceRoot(const SubscriptionOnboardingPanel());
      case AppAccessKind.ready:
        panelStack.replaceRoot(shellForRole(access.role!));
    }
  }
}
