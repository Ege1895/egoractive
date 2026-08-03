import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'base_panel.dart';

part 'panel_stack_controller.g.dart';

@Riverpod(keepAlive: true)
class PanelStackController extends _$PanelStackController {
  bool Function()? _activeBackHandler;
  final Map<BasePanel, VoidCallback> _showCallbacks = {};
  final Map<BasePanel, VoidCallback> _hideCallbacks = {};

  @override
  List<BasePanel> build() => [];

  void push(BasePanel panel) => _updateStack([...state, panel]);

  void pop() {
    if (state.length <= 1) return;
    _updateStack(state.sublist(0, state.length - 1));
  }

  void popToRoot() {
    if (state.length <= 1) return;
    _updateStack([state.first]);
  }

  /// Tüm stack'i tek bir kökle değiştirir — eski kök geri tuşuyla
  /// erişilemez olur. Splash → giriş ekranı ve rol değişince stack
  /// sıfırlanması (F1-11) bu metodu kullanır.
  void replaceRoot(BasePanel panel) => _updateStack([panel]);

  void registerActiveBackHandler(bool Function()? handler) {
    _activeBackHandler = handler;
  }

  bool handleSystemBack() {
    if (_activeBackHandler?.call() ?? false) return true;
    if (state.length > 1) {
      pop();
      return true;
    }
    return false;
  }

  // Panel State'leri initState/dispose içinde kendilerini burada kaydeder —
  // eski panelin onPanelHide()'ı, yenisinin onPanelShow()'undan önce, çağrı
  // sırasını mount zamanlamasından bağımsız garanti eder.
  void registerPanelCallbacks(
    BasePanel panel, {
    required VoidCallback onShow,
    required VoidCallback onHide,
  }) {
    _showCallbacks[panel] = onShow;
    _hideCallbacks[panel] = onHide;
    if (identical(state.isEmpty ? null : state.last, panel)) {
      onShow();
    }
  }

  void unregisterPanelCallbacks(BasePanel panel) {
    _showCallbacks.remove(panel);
    _hideCallbacks.remove(panel);
  }

  void _updateStack(List<BasePanel> next) {
    final previousTop = state.isEmpty ? null : state.last;
    final nextTop = next.isEmpty ? null : next.last;
    state = next;
    if (identical(previousTop, nextTop)) return;
    if (previousTop != null) _hideCallbacks[previousTop]?.call();
    if (nextTop != null) _showCallbacks[nextTop]?.call();
  }
}
