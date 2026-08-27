import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/reports/ui/panels/admin_dashboard_panel.dart';
import '../constants/deep_link_constants.dart';
import '../panels/panel_stack_controller.dart';
import '../router/app_access.dart';
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

  /// F5-18 — ilk link'in işlenmesi (soğuk başlangıç) BİLEREK `await`
  /// edilmiyor: `_handle` içindeki `appAccessProvider` beklemesi, Firebase
  /// Auth'un kalıcı oturumu geri yüklemesini bekleyebiliyor. Bunu `main()`
  /// içinde `runApp()`'tan ÖNCE bloklarcasına beklemek, uygulamanın kendi
  /// giriş/oturum çözümleme akışıyla (bkz. `app_access.dart`'taki "gerçek
  /// cihazda kalıcı giriş kilitlenmesi" notu) yarışıp aynı sınıfta bir
  /// kilitlenmeye yol açıyordu (rapor mailindeki linkten açılışta
  /// gözlemlendi — giriş ekranı takılı kalıp bir daha ilerlemiyordu).
  Future<void> init(ProviderContainer container) async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) unawaited(_handle(container, initialUri));

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
        // olabilir — burada AYRI/erken bir `currentRoleProvider` okuması
        // YAPILMIYOR: uygulamanın kendi UI'ının da beklediği aynı
        // `appAccessProvider` beklenir, böylece hiçbir zaman normal giriş
        // akışının önüne geçilmez/onunla yarışılmaz. İlk değer `ready` +
        // admin değilse (hâlâ giriş ekranındaysa, salon askıya alınmışsa
        // vb.) sessizce yok sayılır.
        final access = await container.read(appAccessProvider.future);
        if (access.kind != AppAccessKind.ready ||
            access.role != AppRole.admin) {
          return;
        }
        container
            .read(panelStackControllerProvider.notifier)
            .push(const AdminDashboardPanel());
    }
  }

  void dispose() {
    unawaited(_subscription?.cancel());
  }
}
