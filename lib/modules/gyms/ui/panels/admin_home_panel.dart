import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../notifications/ui/panels/admin_notifications_panel.dart';
import '../../../trainers/ui/panels/admin_trainer_management_panel.dart';
import '../../controller/admin_home_controller.dart';
import '../../controller/gym_profile_controller.dart';
import '../../domain/admin_home_state.dart';

/// Admin 1 · Ana Sayfa (Özet Dashboard) — Ana Sayfa sekmesi kökü.
class AdminHomePanel extends ConsumerWidget {
  const AdminHomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(adminHomeControllerProvider);
    final profile = ref.watch(gymProfileControllerProvider);
    final panelStack = ref.read(panelStackControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.lg,
            AppSpacing.screenEdge,
            AppSpacing.lg,
          ),
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  ),
                  alignment: Alignment.center,
                  child: profile.logoUrl.isEmpty
                      ? Icon(
                          Icons.fitness_center_rounded,
                          color: colors.onPrimaryContainer,
                          size: 20,
                        )
                      : Image.network(
                          profile.logoUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.fitness_center_rounded,
                            color: colors.onPrimaryContainer,
                            size: 20,
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.monthLabel,
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                      Text(
                        profile.name,
                        style: typography.headingMedium.copyWith(
                          color: colors.onSurface,
                          fontSize: 19,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => panelStack.push(const AdminNotificationsPanel()),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.outlineStrong),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                children: [
                  ProgressRing(
                    size: 260,
                    strokeWidth: 12,
                    progress: state.completionRatio,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '%${(state.completionRatio * 100).round()}',
                          style: typography.dataMedium.copyWith(
                            color: colors.onSurface,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'tamamlanan',
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      children: [
                        _StatRow(
                          label: 'Toplam seans',
                          value: '${state.totalSessions}',
                          valueColor: colors.onSurface,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _StatRow(
                          label: 'Tamamlanan',
                          value: '${state.completedSessions}',
                          valueColor: colors.success,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _StatRow(
                          label: 'İptal',
                          value: '${state.cancelledSessions}',
                          valueColor: colors.error,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: 'Tahmini ciro',
                    value: '₺${state.estimatedRevenueTl}',
                    note: 'Bu ay',
                    noteColor: colors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricTile(
                    label: 'Gider',
                    value: '₺${state.expensesTl}',
                    note: 'Bu ay',
                    noteColor: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'ANTRENÖR PERFORMANSI',
              style: typography.caption.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: state.trainerPerformance.isEmpty
                  ? Column(
                      children: [
                        Text(
                          'Henüz antrenör yok.',
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: '+ Antrenör ekle',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => panelStack.push(
                            const AdminTrainerManagementPanel(),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        for (
                          var i = 0;
                          i < state.trainerPerformance.length;
                          i++
                        ) ...[
                          _TrainerPerformanceRow(
                            performance: state.trainerPerformance[i],
                          ),
                          if (i < state.trainerPerformance.length - 1)
                            const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'ÖDEME VAKTİ YAKLAŞAN',
              style: typography.caption.copyWith(
                color: colors.onWarningContainer,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(
                  color: colors.warning.withValues(alpha: 0.25),
                ),
              ),
              child: state.duePaymentMemberCount == 0
                  ? Text(
                      'Bekleyen ödeme yok.',
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${state.duePaymentMemberCount} üyenin ödemesi bekleniyor',
                            style: typography.bodyLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '₺${state.duePaymentTotalTl}',
                          style: typography.headingSmall.copyWith(
                            color: colors.onWarningContainer,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Geri bildirimler',
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Toplam ${state.feedbackCount} değerlendirme',
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${state.feedbackCount}',
                      style: typography.headingSmall.copyWith(
                        fontSize: 16,
                        color: colors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: typography.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: typography.headingSmall.copyWith(
            color: valueColor,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.note,
    required this.noteColor,
  });

  final String label;
  final String value;
  final String note;
  final Color noteColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: typography.dataMedium.copyWith(
              color: colors.onSurface,
              fontSize: 21,
            ),
          ),
          Text(
            note,
            style: typography.caption.copyWith(color: noteColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TrainerPerformanceRow extends StatelessWidget {
  const _TrainerPerformanceRow({required this.performance});

  final TrainerPerformance performance;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                performance.name,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              '${performance.sessionCount} seans',
              style: typography.headingSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: performance.ratio.clamp(0, 1),
            minHeight: 8,
            backgroundColor: colors.surfaceRaised,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
      ],
    );
  }
}
