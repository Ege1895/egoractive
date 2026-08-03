import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panel_stack_controller.dart';

class PanelStackView extends ConsumerWidget {
  const PanelStackView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stack = ref.watch(panelStackControllerProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(panelStackControllerProvider.notifier).handleSystemBack();
      },
      child: Stack(
        children: [
          for (final panel in stack)
            Visibility(
              key: ObjectKey(panel),
              visible: identical(panel, stack.last),
              maintainState: true,
              maintainAnimation: true,
              maintainSize: false,
              child: panel,
            ),
        ],
      ),
    );
  }
}
