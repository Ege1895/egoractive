import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/trend_bar_chart.dart';
import '../../controller/measurements_controller.dart';
import '../../domain/measurement_metric.dart';
import '../../domain/measurements_state.dart';
import '../widgets/measurement_avatar.dart';
import 'add_measurement_panel.dart';

/// Üye · Ölçümlerim (Ölçümlerim sekmesi kökü) — avatar / grafik geçişi.
class MeasurementsPanel extends ConsumerWidget {
  const MeasurementsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(measurementsControllerProvider);
    final controller = ref.read(measurementsControllerProvider.notifier);
    final isAvatar = state.viewMode == MeasurementsViewMode.avatar;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ölçümlerim', style: typography.headingLarge.copyWith(color: colors.onSurface)),
                        Text(
                          isAvatar
                              ? 'Son ölçüm 12 Temmuz · noktalara dokunarak değerleri gör'
                              : 'metrik çiplerine dokun',
                          style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ),
                  _ViewToggleChip(
                    label: isAvatar ? 'Grafik' : 'Avatar',
                    onTap: () => controller.setViewMode(
                      isAvatar ? MeasurementsViewMode.chart : MeasurementsViewMode.avatar,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isAvatar ? const _AvatarView() : const _ChartView(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  const _ViewToggleChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: colors.outlineStrong),
          ),
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(fontSize: 14, color: colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _AvatarView extends ConsumerWidget {
  const _AvatarView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(measurementsControllerProvider);
    final controller = ref.read(measurementsControllerProvider.notifier);
    final selectedPoint = state.points[state.selectedMetric]!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
      children: [
        Center(
          child: MeasurementAvatar(
            points: state.points,
            selected: state.selectedMetric,
            onSelect: controller.selectPoint,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seçili nokta', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                      Text(
                        state.selectedMetric.label,
                        style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 19),
                      ),
                    ],
                  ),
                  Text.rich(
                    TextSpan(
                      text: selectedPoint.value,
                      style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 32),
                      children: [
                        TextSpan(text: ' cm', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 15)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
                    decoration: BoxDecoration(
                      color: selectedPoint.isImprovement ? colors.successContainer : colors.primaryContainer,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      selectedPoint.delta,
                      style: typography.caption.copyWith(
                        color: selectedPoint.isImprovement ? colors.onSuccessContainer : colors.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(selectedPoint.since, style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _AddMeasurementButton(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartView extends ConsumerWidget {
  const _ChartView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(measurementsControllerProvider);
    final controller = ref.read(measurementsControllerProvider.notifier);
    final series = state.series[state.selectedMetric]!;
    final lastValue = series.values.last;
    final prevValue = series.values.length > 1 ? series.values[series.values.length - 2] : lastValue;
    final diff = lastValue - prevValue;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final metric in MeasurementMetric.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _MetricChip(
                    label: metric.label,
                    selected: metric == state.selectedMetric,
                    onTap: () => controller.selectPoint(metric),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${series.metric.label} · son ölçüm', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                      Text.rich(
                        TextSpan(
                          text: lastValue.toStringAsFixed(1).replaceAll('.', ','),
                          style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 40),
                          children: [
                            TextSpan(text: ' cm', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 17)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
                        decoration: BoxDecoration(
                          color: diff == 0 ? colors.surfaceRaised : (diff < 0 ? colors.successContainer : colors.primaryContainer),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(
                          diff == 0
                              ? 'değişim yok'
                              : '${diff < 0 ? '−' : '+'}${diff.abs().toStringAsFixed(1).replaceAll('.', ',')} cm',
                          style: typography.caption.copyWith(
                            fontSize: 12,
                            color: diff == 0 ? colors.onSurfaceMuted : (diff < 0 ? colors.onSuccessContainer : colors.onPrimaryContainer),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text('6 ayda ${series.totalDeltaLabel}', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              TrendBarChart(
                values: series.values,
                labels: series.months,
                valueFormatter: (value) => value.toStringAsFixed(1).replaceAll('.', ','),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('ÖLÇÜM GEÇMİŞİ', style: typography.caption.copyWith(color: colors.onSurfaceMuted, letterSpacing: 1.2)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            children: [
              for (var i = series.values.length - 1; i >= 0 && i >= series.values.length - 4; i--)
                _HistoryRow(
                  date: i == series.values.length - 1 ? 'Son ölçüm' : series.months[i],
                  value: series.values[i],
                  delta: i == 0 ? null : series.values[i] - series.values[i - 1],
                  showDivider: i > 0 && i >= series.values.length - 4,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _AddMeasurementButton(),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.selected, required this.onTap});

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
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: selected ? colors.primary : colors.outlineStrong),
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
  const _HistoryRow({required this.date, required this.value, required this.delta, required this.showDivider});

  final String date;
  final double value;
  final double? delta;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final deltaLabel = delta == null
        ? '—'
        : delta == 0
            ? 'değişim yok'
            : '${delta! < 0 ? '−' : '+'}${delta!.abs().toStringAsFixed(1).replaceAll('.', ',')}';
    final deltaColor = delta == null || delta == 0
        ? colors.onSurfaceMuted
        : (delta! < 0 ? colors.success : colors.onPrimaryContainer);

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: colors.outline)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date, style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
          Row(
            children: [
              Text(
                '${value.toStringAsFixed(1).replaceAll('.', ',')} cm',
                style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(deltaLabel, style: typography.caption.copyWith(color: deltaColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddMeasurementButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        onTap: () => ref.read(panelStackControllerProvider.notifier).push(const AddMeasurementPanel()),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: AppSpacing.primaryActionHeight),
          alignment: Alignment.center,
          child: Text(
            'Yeni ölçüm ekle',
            style: context.appTypography.headingSmall.copyWith(fontSize: 15, color: colors.onPrimary),
          ),
        ),
      ),
    );
  }
}
