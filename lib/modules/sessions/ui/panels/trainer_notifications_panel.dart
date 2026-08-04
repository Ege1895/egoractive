import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/trainer_notifications_controller.dart';
import '../../domain/trainer_notification.dart';
import 'attendance_notification_detail_panel.dart';

/// Antrenör · Bildirimler — Ana Sayfa'daki zil ikonundan açılır, her satır
/// P3-8'deki bildirim detayına götürür.
class TrainerNotificationsPanel extends BasePanel {
  const TrainerNotificationsPanel({super.key});

  @override
  ConsumerState<TrainerNotificationsPanel> createState() => _TrainerNotificationsPanelState();
}

class _TrainerNotificationsPanelState extends BasePanelState<TrainerNotificationsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final notifications = ref.watch(trainerNotificationsControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
                  const SizedBox(width: AppSpacing.md),
                  Text('Bildirimler', style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 24)),
                ],
              ),
            ),
            Expanded(
              child: notifications.isEmpty
                  ? Center(
                      child: Text(
                        'Henüz bildirim yok.',
                        style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                      children: [
                        for (final n in notifications) _NotificationRow(notification: n),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationRow extends ConsumerWidget {
  const _NotificationRow({required this.notification});

  final TrainerNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: () => ref
          .read(panelStackControllerProvider.notifier)
          .push(AttendanceNotificationDetailPanel(notification: notification)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: notification.answerIsPositive ? colors.success : colors.warning,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notification.title, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
                  Text(notification.body, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
