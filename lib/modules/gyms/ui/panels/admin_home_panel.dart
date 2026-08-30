import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../trainers/ui/panels/admin_trainer_management_panel.dart';
import '../../controller/admin_home_controller.dart';
import '../../controller/gym_profile_controller.dart';
import '../../domain/admin_home_state.dart';
import 'gym_info_panel.dart';

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
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  onTap: () => panelStack.push(const GymInfoPanel()),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: profile.logoUrl.isEmpty
                            ? Icon(
                                Icons.fitness_center_rounded,
                                color: colors.onPrimaryContainer,
                                size: 20,
                              )
                            : CachedNetworkImage(
                                imageUrl: profile.logoUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Icon(
                                  Icons.fitness_center_rounded,
                                  color: colors.onPrimaryContainer,
                                  size: 20,
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (state.monthLabel.isNotEmpty)
                              Text(
                                state.monthLabel,
                                overflow: TextOverflow.ellipsis,
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                              ),
                            Text(
                              profile.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.headingMedium.copyWith(
                                color: colors.onSurface,
                                fontSize: 19,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    size: 84,
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
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAdminHomeCompletedWord,
                            ),
                          ),
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
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAdminHomeTotalSessionsLabel,
                            ),
                          ),
                          value: '${state.totalSessions}',
                          valueColor: colors.onSurface,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _StatRow(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAdminHomeCompletedLabel,
                            ),
                          ),
                          value: '${state.completedSessions}',
                          valueColor: colors.success,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _StatRow(
                          label: ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonIptalLabel),
                          ),
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
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsAdminHomeEstimatedRevenueLabel,
                      ),
                    ),
                    value: '₺${state.estimatedRevenueTl}',
                    note: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsAdminHomeThisMonthNote,
                      ),
                    ),
                    noteColor: colors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricTile(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsAdminHomeExpenseLabel,
                      ),
                    ),
                    value: '₺${state.expensesTl}',
                    note: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsAdminHomeThisMonthNote,
                      ),
                    ),
                    noteColor: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.gymsAdminHomeTrainerPerformanceSection,
                ),
              ),
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
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAdminHomeNoTrainersMessage,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAdminHomeAddTrainerButton,
                            ),
                          ),
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
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.gymsAdminHomeUpcomingPaymentsSection,
                ),
              ),
              style: typography.caption.copyWith(
                color: colors.primary,
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
                  color: colors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: state.duePaymentMemberCount == 0
                  ? Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys
                              .gymsAdminHomeNoPendingPaymentsMessage,
                        ),
                      ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .gymsAdminHomeDuePaymentMembersTemplate,
                                  ),
                                )
                                .replaceAll(
                                  '{count}',
                                  '${state.duePaymentMemberCount}',
                                ),
                            style: typography.bodyLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          '₺${state.duePaymentTotalTl}',
                          style: typography.headingSmall.copyWith(
                            color: colors.primary,
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
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsSettingsNavFeedback,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .gymsAdminHomeTotalFeedbackTemplate,
                                ),
                              )
                              .replaceAll('{count}', '${state.feedbackCount}'),
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
