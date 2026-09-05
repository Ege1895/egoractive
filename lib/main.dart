import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/constants/ad_constants.dart';
import 'core/deep_links/app_deep_link_service.dart';
import 'core/locale/locale_controller.dart';
import 'core/locale/locale_prefs.dart';
import 'core/onboarding/onboarding_prefs.dart';
import 'core/panels/panel_stack_controller.dart';
import 'core/panels/panel_stack_view.dart';
import 'core/perf/perf_trace.dart';
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
import 'shared/widgets/app_phone_field_prefs.dart';

/// Widget ağacı dışından (bildirim servisi gibi) `PanelStackController`'a
/// erişebilmek için paylaşılan container — `UncontrolledProviderScope` bunu
/// widget ağacına da bağlıyor.
final _providerContainer = ProviderContainer();

void main() async {
  // F10-1/F10-2 — açılış zincirinin her adımı ayrı ölçülüyor. `runApp()`
  // öncesinde SADECE ağa çıkmayan, ilk kare için gerçekten gerekli olan
  // adımlar var; ağa çıkan her şey `_initInBackground()`'a taşındı.
  PerfTrace.startApp();
  WidgetsFlutterBinding.ensureInitialized();
  PerfTrace.begin('firebase_init');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  PerfTrace.end('firebase_init');

  // Kapalı testte uygulama testerların cihazında hiç açılmadan çöktü ve
  // elimizde tek veri "crash oluyor" mailiydi; yığın izini ancak emülatörde
  // temiz kurulum yaparak üretebildik (bkz. `android/app/proguard-rules.pro`).
  // Crashlytics, aynı durumda çökmeyi doğrudan konsola taşıyor.
  //
  // `Firebase.initializeApp`'ten HEMEN sonra kuruluyor: daha erkeye almak
  // mümkün değil (Firebase başlatılmadan Crashlytics örneği yok), bu yüzden
  // Firebase'den önce oluşan native çökmeler yine yakalanamaz — Android/iOS
  // SDK'sı süreç kuruluşunda kendi handler'ını taktığı için pratikte
  // çoğu native çökme yine de rapor edilir.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  // F10-2 — bu üçü de SharedPreferences (yerel disk, ağ yok) ve ilk kare
  // çizilmeden hazır olmaları gerekiyor (dil seçimi, onboarding durumu,
  // son seçilen ülke kodu). Ardışık yerine paralel bekleniyor.
  PerfTrace.begin('prefs_init');
  await Future.wait([
    LocalePrefs.init(),
    OnboardingPrefs.init(),
    AppPhoneFieldPrefs.init(),
  ]);
  PerfTrace.end('prefs_init');
  // F10-2 — SADECE varsayılanlar (ağa çıkmaz, ~ms). Asıl fetch runApp'ten
  // sonra, arka planda; bkz. `RemoteConfigService.fetchInBackground`.
  PerfTrace.begin('remote_config_defaults');
  await const RemoteConfigService().applyDefaults();
  PerfTrace.end('remote_config_defaults');
  unawaited(MobileAds.instance.initialize());
  if (debugTestDeviceIds.isNotEmpty) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: debugTestDeviceIds),
    );
  }
  // Sadece bir handler kaydı (ağ yok) — arka plan bildirimlerinin
  // yakalanabilmesi için isolate ayağa kalkmadan önce kurulmuş olmalı,
  // bu yüzden `runApp()` öncesinde kalıyor.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(
    UncontrolledProviderScope(
      container: _providerContainer,
      child: const EgoractiveApp(),
    ),
  );
  // Bu geri çağırma ilk kare GERÇEKTEN çizildikten sonra tetiklenir —
  // "uygulama açılış → ilk kare" hedefinin (F10-2: < 1,5 sn) ölçümü.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    PerfTrace.sinceAppStart('İLK KARE');
  });
  // F10-2 — buradan aşağısı ilk kareyi BEKLETMEZ. Üçü de ağa çıkıyor
  // (RC fetch 255 KB, FCM token kaydı + Firestore yazması, deep link
  // kanalı) ve hiçbiri ilk karenin çizilmesi için gerekli değil.
  unawaited(_initInBackground());
}

/// `runApp()` sonrasında, kullanıcı zaten giriş ekranını görürken çalışan
/// kurulum adımları. Her biri kendi `try/catch`'iyle sarılı — burada
/// oluşacak bir hata `unawaited` olduğu için yakalanmazsa uygulamayı
/// çökertebilirdi.
Future<void> _initInBackground() async {
  PerfTrace.begin('bg_remote_config_fetch');
  try {
    await const RemoteConfigService().fetchInBackground();
  } on Exception catch (error) {
    debugPrint('Remote Config arka plan fetch başarısız: $error');
  }
  PerfTrace.end('bg_remote_config_fetch');

  PerfTrace.begin('bg_push_init');
  try {
    await PushNotificationService().init(_providerContainer);
  } on Exception catch (error) {
    debugPrint(
      'Push bildirim kurulumu başarısız oldu, uygulama yine de açılıyor: $error',
    );
  }
  PerfTrace.end('bg_push_init');

  PerfTrace.begin('bg_deeplink_init');
  try {
    await AppDeepLinkService().init(_providerContainer);
  } on Exception catch (error) {
    debugPrint(
      'Deep link kurulumu başarısız oldu, uygulama yine de açılıyor: $error',
    );
  }
  PerfTrace.end('bg_deeplink_init');
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
        ...PhoneFieldLocalization.delegates,
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
