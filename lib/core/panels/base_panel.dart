import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'panel_stack_controller.dart';

abstract class BasePanel extends ConsumerStatefulWidget {
  const BasePanel({super.key});
}

abstract class BasePanelState<T extends BasePanel> extends ConsumerState<T> {
  bool _isPanelShown = false;
  late final PanelStackController _stackController;

  @override
  void initState() {
    super.initState();
    _stackController = ref.read(panelStackControllerProvider.notifier);
    _stackController.registerPanelCallbacks(
      widget,
      onShow: _handleShow,
      onHide: _handleHide,
    );
  }

  @override
  Widget build(BuildContext context);

  void onPanelShow() {}

  void onPanelHide() {}

  bool onBackRequested() => false;

  void _handleShow() {
    if (_isPanelShown) return;
    _isPanelShown = true;
    _stackController.registerActiveBackHandler(onBackRequested);
    onPanelShow();
  }

  void _handleHide() {
    if (!_isPanelShown) return;
    _isPanelShown = false;
    _stackController.registerActiveBackHandler(null);
    onPanelHide();
  }

  @override
  void dispose() {
    _stackController.unregisterPanelCallbacks(widget);
    super.dispose();
  }
}
