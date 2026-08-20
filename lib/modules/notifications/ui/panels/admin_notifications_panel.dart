import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Admin · Bildirimler — Ana Sayfa'daki zil ikonundan açılır. Salona gelen
/// bildirimleri (ör. yaklaşan ödeme, biten paket) listeleyecek — hangi
/// olayların burada görüneceği henüz tanımlanmadı, bu yüzden şimdilik
/// placeholder. `SendNotificationPanel` (üyelere bildirim GÖNDERME) ayrı bir
/// akış — Ayarlar'dan erişilmeye devam ediyor.
class AdminNotificationsPanel extends BasePanel {
  const AdminNotificationsPanel({super.key});

  @override
  ConsumerState<AdminNotificationsPanel> createState() =>
      _AdminNotificationsPanelState();
}

class _AdminNotificationsPanelState
    extends BasePanelState<AdminNotificationsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  AppBackButton(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.notificationsTitle),
                    ),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  ref.watch(
                    rcTextProvider(
                      RemoteConfigKeys.sessionsTrainerNotificationsEmptyState,
                    ),
                  ),
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
