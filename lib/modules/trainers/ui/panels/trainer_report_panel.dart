import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../controller/trainer_report_controller.dart';
import '../../domain/trainer_report_state.dart';

/// Antrenör 2 · Seans Raporum (Raporum sekmesi kökü) — dönem seçici
/// (haftalık/aylık/tüm zamanlar/özel) + tarih aralığı + Birebir/Grup
/// kırılımı. Uygulamada bir prim/komisyon sistemi yok.
class TrainerReportPanel extends ConsumerWidget {
  const TrainerReportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final report = ref.watch(trainerReportControllerProvider);
    final controller = ref.read(trainerReportControllerProvider.notifier);
    final soloLabel = ref.watch(
      rcTextProvider(RemoteConfigKeys.trainersReportOneOnOneToggle),
    );
    final groupLabel = ref.watch(
      rcTextProvider(RemoteConfigKeys.trainersReportGroupToggle),
    );
    final isCustom = report.period == TrainerReportPeriod.custom;

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
            Text(
              ref.watch(rcTextProvider(RemoteConfigKeys.trainersReportTitle)),
              style: typography.headingLarge.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _PeriodChip(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersReportPeriodWeekly,
                      ),
                    ),
                    selected: report.period == TrainerReportPeriod.weekly,
                    onTap: () =>
                        controller.setPeriod(TrainerReportPeriod.weekly),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _PeriodChip(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersReportPeriodMonthly,
                      ),
                    ),
                    selected: report.period == TrainerReportPeriod.monthly,
                    onTap: () =>
                        controller.setPeriod(TrainerReportPeriod.monthly),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _PeriodChip(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersReportPeriodAllTime,
                      ),
                    ),
                    selected: report.period == TrainerReportPeriod.allTime,
                    onTap: () =>
                        controller.setPeriod(TrainerReportPeriod.allTime),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _PeriodChip(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersReportPeriodCustom,
                      ),
                    ),
                    selected: isCustom,
                    onTap: () =>
                        controller.setPeriod(TrainerReportPeriod.custom),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersReportStartDateFieldLabel,
                      ),
                    ),
                    value: report.startDate,
                    onTap: !isCustom
                        ? null
                        : () => showNativeDatePicker(
                            context: context,
                            initial: report.periodStart,
                            firstDate: report.gymJoinedAt,
                            lastDate: report.periodEnd,
                            onSelected: (date) =>
                                controller.setCustomRange(start: date),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _DateTile(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersReportEndDateFieldLabel,
                      ),
                    ),
                    value: report.endDate,
                    onTap: !isCustom
                        ? null
                        : () => showNativeDatePicker(
                            context: context,
                            initial: report.periodEnd,
                            firstDate: report.periodStart,
                            lastDate: DateTime.now(),
                            onSelected: (date) =>
                                controller.setCustomRange(end: date),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final b in report.breakdown) ...[
              _BreakdownCard(
                breakdown: b,
                soloLabel: soloLabel,
                groupLabel: groupLabel,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
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
      color: selected ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
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

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final content = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        border: Border.all(
          color: onTap != null ? colors.primary : colors.outline,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: typography.headingSmall.copyWith(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.edit_calendar_outlined, size: 16, color: colors.primary),
          ],
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      onTap: onTap,
      child: content,
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({
    required this.breakdown,
    required this.soloLabel,
    required this.groupLabel,
  });

  final TrainerReportBreakdown breakdown;
  final String soloLabel;
  final String groupLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  breakdown.title,
                  style: typography.headingSmall.copyWith(
                    color: colors.onSurface,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${breakdown.total}',
                style: typography.dataLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(label: soloLabel, value: '${breakdown.solo}'),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: groupLabel,
                  value: '${breakdown.group}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

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
            style: typography.headingSmall.copyWith(
              color: colors.onSurface,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}
