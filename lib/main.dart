import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/panels/demo_panels.dart';
import 'core/panels/panel_stack_controller.dart';
import 'core/panels/panel_stack_view.dart';

void main() {
  runApp(const ProviderScope(child: EgoractiveApp()));
}

class EgoractiveApp extends StatelessWidget {
  const EgoractiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Egoractive',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF05A6FA),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
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
      ref.read(panelStackControllerProvider.notifier).push(const DemoRootPanel());
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
