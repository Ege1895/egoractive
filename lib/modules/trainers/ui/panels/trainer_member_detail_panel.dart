import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/trend_bar_chart.dart';
import '../../../measurements/ui/panels/measurements_panel.dart';
import '../../../sessions/ui/widgets/create_session_sheet.dart';
import '../../controller/trainer_member_detail_controller.dart';
import '../../domain/trainer_member_detail.dart';
import '../../domain/trainer_metric.dart';

/// Antrenör 4 · Üye Detayı — antrenör görünümü, fiyat gösterilmez.
class TrainerMemberDetailPanel extends BasePanel {
  const TrainerMemberDetailPanel({required this.memberId, super.key});

  final String memberId;

  @override
  ConsumerState<TrainerMemberDetailPanel> createState() =>
      _TrainerMemberDetailPanelState();
}

class _TrainerMemberDetailPanelState
    extends BasePanelState<TrainerMemberDetailPanel> {
  bool _metricPickerOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final detail = ref.watch(
      trainerMemberDetailControllerProvider(widget.memberId),
    );
    final controller = ref.read(
      trainerMemberDetailControllerProvider(widget.memberId).notifier,
    );

    if (detail.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (detail.notFound) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenEdge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBackButton(
                  onTap: () =>
                      ref.read(panelStackControllerProvider.notifier).pop(),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  ref.watch(
                    rcTextProvider(RemoteConfigKeys.membersDetailNotFound),
                  ),
                  style: typography.headingSmall.copyWith(
                    color: colors.onSurface,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final series = detail.seriesByMetric[detail.selectedMetric]!;

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
                      rcTextProvider(RemoteConfigKeys.commonUyeDetayiTitle),
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                detail.initials,
                                style: typography.headingSmall.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.name,
                                    style: typography.headingMedium.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 19,
                                    ),
                                  ),
                                  Text(
                                    '${formatTrPhoneDisplay(detail.phone)} · ${detail.memberSince}',
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoTile(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .trainersMemberDetailRemainingSessionsLabel,
                                  ),
                                ),
                                value: '${detail.remainingSessions}',
                                valueColor: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _InfoTile(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .trainersMemberDetailPackageEndLabel,
                                  ),
                                ),
                                value: detail.packageEndDate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Material(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusInner,
                                ),
                                child: InkWell(
                                  onTap: () => showCreateSessionSheet(
                                    context,
                                    ref,
                                    DateTime.now(),
                                    lockedTrainerId: ref
                                        .read(authStateProvider)
                                        .valueOrNull
                                        ?.uid,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusInner,
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 44,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .trainersMemberDetailCreateSessionButton,
                                        ),
                                      ),
                                      style: typography.headingSmall.copyWith(
                                        fontSize: 15,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Material(
                                color: colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusInner,
                                ),
                                child: InkWell(
                                  onTap: () => ref
                                      .read(
                                        panelStackControllerProvider.notifier,
                                      )
                                      .push(
                                        MeasurementsPanel(
                                          memberId: widget.memberId,
                                          memberName: detail.name,
                                        ),
                                      ),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusInner,
                                  ),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minHeight: 44,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .trainersMemberDetailAddMeasurementButton,
                                        ),
                                      ),
                                      style: typography.headingSmall.copyWith(
                                        fontSize: 15,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    onTap: () =>
                        setState(() => _metricPickerOpen = !_metricPickerOpen),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .commonOlcum6AySectionHeader,
                                  ),
                                ),
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                detail.selectedMetric.label,
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _metricPickerOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: colors.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_metricPickerOpen) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final metric in TrainerMetric.values)
                          _MetricChip(
                            label: metric.label,
                            selected: metric == detail.selectedMetric,
                            onTap: () => controller.selectMetric(metric),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: TrendBarChart(
                      values: series.values,
                      labels: series.months,
                      height: 132,
                      valueFormatter: (value) =>
                          value.toStringAsFixed(1).replaceAll('.', ','),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.commonDersGecmisiSectionHeader,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < detail.history.length; i++)
                          _HistoryRow(
                            entry: detail.history[i],
                            showDivider: i < detail.history.length - 1,
                          ),
                      ],
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

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
          ),
          Text(
            value,
            style: typography.headingMedium.copyWith(
              color: valueColor ?? colors.onSurface,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          constraints: const BoxConstraints(minHeight: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineStrong,
            ),
          ),
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.showDivider});

  final SessionHistoryEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.date,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
              Text(
                entry.type,
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
          Text(
            entry.stateLabel,
            style: typography.caption.copyWith(
              color: entry.isPositive ? colors.success : colors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
