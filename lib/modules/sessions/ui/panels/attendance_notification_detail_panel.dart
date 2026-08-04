import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/trainer_notification.dart';

/// Antrenör 8 · Ders Onayı Bildirimi Detayı — üyenin gelicem/gelmeyeceğim
/// cevabını gösteren mini panel.
class AttendanceNotificationDetailPanel extends BasePanel {
  const AttendanceNotificationDetailPanel({required this.notification, super.key});

  final TrainerNotification notification;

  @override
  ConsumerState<AttendanceNotificationDetailPanel> createState() => _AttendanceNotificationDetailPanelState();
}

class _AttendanceNotificationDetailPanelState extends BasePanelState<AttendanceNotificationDetailPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final n = widget.notification;
    final answerColor = n.answerIsPositive ? colors.success : colors.warning;
    final answerContainer = n.answerIsPositive ? colors.successContainer : colors.warningContainer;
    final onAnswerContainer = n.answerIsPositive ? colors.onSuccessContainer : colors.onWarningContainer;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(n.memberInitials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 17)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                      Text(n.sessionMeta, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: answerContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      border: Border.all(color: answerColor.withValues(alpha: 0.32)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cevabı', style: typography.caption.copyWith(color: onAnswerContainer)),
                        Text(n.answerLabel, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cevap saati', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                        Text(n.answeredAt, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (n.note != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Üyenin notu', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                    const SizedBox(height: AppSpacing.xs),
                    Text('"${n.note}"', style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, height: 1.4)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Takvime dön',
                    onPressed: () => ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(label: 'Seansı ertele', variant: AppButtonVariant.secondary, onPressed: () {}),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
