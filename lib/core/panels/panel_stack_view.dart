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
      // Tüm panellerde ortak: bir inputfield'a odaklanmışken ekranın boş bir
      // yerine dokununca klavye kapanmalı. Önceden bazı panellerde (ör.
      // GymSetupPanel) bu yerelde ayrıca uygulanmıştı, çoğunda hiç yoktu —
      // burada merkezi olarak uygulanınca her panel için garanti edilir.
      // `onTap` bir üst seviyede olduğu için alttaki buton/InkWell'lerin
      // kendi tap'lerini yakalamasını engellemez.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
      ),
    );
  }
}
