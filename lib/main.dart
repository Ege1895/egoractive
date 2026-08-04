import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/panels/panel_stack_controller.dart';
import 'core/panels/panel_stack_view.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/theme_controller.dart';
import 'modules/auth/ui/panels/splash_panel.dart';

void main() {
  runApp(const ProviderScope(child: EgoractiveApp()));
}

class EgoractiveApp extends ConsumerWidget {
  const EgoractiveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(themeControllerProvider);
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
    if (stack.isEmpty) {
      return const Scaffold(body: SizedBox.shrink());
    }
    return const PanelStackView();
  }
}
