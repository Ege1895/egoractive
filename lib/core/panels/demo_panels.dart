// Geçici demo — F1-4 (PanelStackController) push/pop/geri tuşu akışını
// manuel doğrulamak için. Gerçek panel modülleri (P1+) devreye girince
// bu dosya ve DemoRootPanel silinir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_panel.dart';
import 'panel_stack_controller.dart';
import 'shell/role_picker_panel.dart';
import '../theme/component_showcase_panel.dart';

class DemoRootPanel extends BasePanel {
  const DemoRootPanel({super.key});

  @override
  ConsumerState<DemoRootPanel> createState() => _DemoRootPanelState();
}

class _DemoRootPanelState extends BasePanelState<DemoRootPanel> {
  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      label: 'A',
      onPushNext: () =>
          ref.read(panelStackControllerProvider.notifier).push(const DemoPanelB()),
    );
  }
}

class DemoPanelB extends BasePanel {
  const DemoPanelB({super.key});

  @override
  ConsumerState<DemoPanelB> createState() => _DemoPanelBState();
}

class _DemoPanelBState extends BasePanelState<DemoPanelB> {
  @override
  Widget build(BuildContext context) {
    return _DemoScaffold(
      label: 'B',
      onPushNext: () =>
          ref.read(panelStackControllerProvider.notifier).push(const DemoPanelC()),
    );
  }
}

class DemoPanelC extends BasePanel {
  const DemoPanelC({super.key});

  @override
  ConsumerState<DemoPanelC> createState() => _DemoPanelCState();
}

class _DemoPanelCState extends BasePanelState<DemoPanelC> {
  @override
  Widget build(BuildContext context) {
    final controller = ref.read(panelStackControllerProvider.notifier);
    return _DemoScaffold(
      label: 'C',
      onPushNext: null,
      extraActions: [
        ('Bileşenleri gör', () => controller.push(const ComponentShowcasePanel())),
        ('Rolleri gör', () => controller.push(const RolePickerPanel())),
      ],
    );
  }
}

class _DemoScaffold extends StatelessWidget {
  const _DemoScaffold({
    required this.label,
    required this.onPushNext,
    this.extraActions = const [],
  });

  final String label;
  final VoidCallback? onPushNext;
  final List<(String, VoidCallback)> extraActions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Panel $label', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            if (onPushNext != null)
              ElevatedButton(
                onPressed: onPushNext,
                child: const Text('Sonrakine git'),
              ),
            for (final (label, onPressed) in extraActions)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton(onPressed: onPressed, child: Text(label)),
              ),
          ],
        ),
      ),
    );
  }
}
