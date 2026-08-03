import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/panels/base_panel.dart';
import 'package:egoractive/core/panels/panel_stack_controller.dart';
import 'package:egoractive/core/panels/panel_stack_view.dart';
import 'package:egoractive/main.dart';

class _DummyPanel extends BasePanel {
  const _DummyPanel(this.id);

  final String id;

  @override
  ConsumerState<_DummyPanel> createState() => _DummyPanelState();
}

class _DummyPanelState extends BasePanelState<_DummyPanel> {
  @override
  Widget build(BuildContext context) => Text(widget.id);
}

class _RecordingPanel extends BasePanel {
  const _RecordingPanel(this.id, this.log);

  final String id;
  final List<String> log;

  @override
  ConsumerState<_RecordingPanel> createState() => _RecordingPanelState();
}

class _RecordingPanelState extends BasePanelState<_RecordingPanel> {
  @override
  void onPanelShow() => widget.log.add('${widget.id}:show');

  @override
  void onPanelHide() => widget.log.add('${widget.id}:hide');

  @override
  Widget build(BuildContext context) => Text(widget.id);
}

void main() {
  group('PanelStackController', () {
    test('push/pop/popToRoot mutate the stack correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(panelStackControllerProvider.notifier);

      notifier.push(const _DummyPanel('A'));
      notifier.push(const _DummyPanel('B'));
      notifier.push(const _DummyPanel('C'));
      expect(container.read(panelStackControllerProvider).map((p) => (p as _DummyPanel).id), ['A', 'B', 'C']);

      notifier.pop();
      expect(container.read(panelStackControllerProvider).map((p) => (p as _DummyPanel).id), ['A', 'B']);

      notifier.push(const _DummyPanel('D'));
      notifier.popToRoot();
      expect(container.read(panelStackControllerProvider).map((p) => (p as _DummyPanel).id), ['A']);

      // Root panel can't be popped.
      notifier.pop();
      expect(container.read(panelStackControllerProvider).map((p) => (p as _DummyPanel).id), ['A']);
    });

    test('handleSystemBack asks the active panel before falling back to pop', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(panelStackControllerProvider.notifier);

      notifier.push(const _DummyPanel('A'));
      notifier.push(const _DummyPanel('B'));

      notifier.registerActiveBackHandler(() => true);
      expect(notifier.handleSystemBack(), isTrue);
      expect(container.read(panelStackControllerProvider), hasLength(2));

      notifier.registerActiveBackHandler(null);
      expect(notifier.handleSystemBack(), isTrue);
      expect(container.read(panelStackControllerProvider), hasLength(1));

      expect(notifier.handleSystemBack(), isFalse);
    });
  });

  group('BasePanel show/hide lifecycle', () {
    testWidgets('onPanelHide of the old top fires before onPanelShow of the new top', (tester) async {
      final log = <String>[];
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: PanelStackView()),
        ),
      );

      container.read(panelStackControllerProvider.notifier).push(_RecordingPanel('A', log));
      await tester.pumpAndSettle();
      expect(log, ['A:show']);

      log.clear();
      container.read(panelStackControllerProvider.notifier).push(_RecordingPanel('B', log));
      await tester.pumpAndSettle();
      expect(log, ['A:hide', 'B:show']);

      log.clear();
      container.read(panelStackControllerProvider.notifier).pop();
      await tester.pumpAndSettle();
      expect(log, ['B:hide', 'A:show']);
    });
  });

  group('Demo panels (A→B→C + system back)', () {
    testWidgets('push flow works and the system back button walks the stack back', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: EgoractiveApp()));
      await tester.pumpAndSettle();
      expect(find.text('Panel A'), findsOneWidget);

      await tester.tap(find.text('Sonrakine git'));
      await tester.pumpAndSettle();
      expect(find.text('Panel B'), findsOneWidget);

      await tester.tap(find.text('Sonrakine git'));
      await tester.pumpAndSettle();
      expect(find.text('Panel C'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Panel B'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Panel A'), findsOneWidget);
    });
  });
}
