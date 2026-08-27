import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/reports/ui/panels/admin_dashboard_panel.dart';
import '../constants/deep_link_constants.dart';
import '../panels/panel_stack_controller.dart';
import '../router/app_router.dart';

/// F5-14 — rapor mailindeki "Uygulamada Gör" butonu (`egoractive://reports`)
/// gibi özel şema linklerini dinler, `PushNotificationService`'teki
/// `_navigateForData` ile aynı desende ilgili panele yönlendirir.
/// `PanelStackController`'a widget ağacı dışından erişmek için aynı
/// `ProviderContainer` paylaşılır (bkz. main.dart).
class AppDeepLinkService {
  AppDeepLinkService();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  Future<void> init(ProviderContainer container) async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) await _handle(container, initialUri);

    _subscription = _appLinks.uriLinkStream.listen(
      (uri) => _handle(container, uri),
      onError: (Object error) =>
          debugPrint('Deep link akışı hata verdi: $error'),
    );
  }

  Future<void> _handle(ProviderContainer container, Uri uri) async {
    if (uri.scheme != appUrlScheme) return;

    switch (uri.host) {
      case reportsDeepLinkHost:
        // Rapor maili sadece admin'e gidiyor ama link forward edilmiş
        // olabilir — admin olmayan bir hesapta açılırsa sessizce yok sayılır
        // (bkz. push_notification_service.dart'taki aynı yaklaşım).
        final role = await container.read(currentRoleProvider.future);
        if (role != AppRole.admin) return;
        container
            .read(panelStackControllerProvider.notifier)
            .push(const AdminDashboardPanel());
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
  }
}
