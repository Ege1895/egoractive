import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/panels/panel_stack_controller.dart';
import 'core/panels/panel_stack_view.dart';
import 'core/remote_config/remote_config_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_color_scheme.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';
import 'modules/auth/ui/panels/phone_login_panel.dart';
import 'modules/auth/ui/panels/splash_panel.dart';
import 'modules/notifications/service/push_notification_service.dart';

/// Widget ağacı dışından (bildirim servisi gibi) `PanelStackController`'a
/// erişebilmek için paylaşılan container — `UncontrolledProviderScope` bunu
/// widget ağacına da bağlıyor.
final _providerContainer = ProviderContainer();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await const RemoteConfigService().init();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await PushNotificationService().init(_providerContainer);
  runApp(UncontrolledProviderScope(container: _providerContainer, child: const EgoractiveApp()));
}

class EgoractiveApp extends ConsumerWidget {
  const EgoractiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeControllerProvider).valueOrNull ?? AppColorScheme.defaultScheme();
    return MaterialApp(
      title: 'Egoractive',
      theme: AppTheme.build(
        colors: colors,
        typography: AppTypography.standard(),
      ),
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

    // F1-11 — tek yönlendirme kaynağı: rol çözülünce ilgili shell'e, oturum
    // var ama claim geçersiz/eksikse login ekranına dönülür. Splash sadece
    // marka gösterimi + basit bir fallback'tir; asıl karar burada verilir.
    ref.listen(currentRoleProvider, (previous, next) {
      next.whenData((role) {
        final panelStack = ref.read(panelStackControllerProvider.notifier);
        if (role != null) {
          panelStack.replaceRoot(shellForRole(role));
        } else if (FirebaseAuth.instance.currentUser != null) {
          FirebaseAuth.instance.signOut();
          panelStack.replaceRoot(const PhoneLoginPanel());
        }
      });
    });

    if (stack.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return const PanelStackView();
  }
}
