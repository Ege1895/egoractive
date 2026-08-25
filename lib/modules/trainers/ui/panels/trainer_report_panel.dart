import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/trainer_report_controller.dart';
import '../../domain/trainer_report_state.dart';

/// Antrenör 2 · Seans Raporum (Raporum sekmesi kökü) — tarih aralığı +
/// Birebir/Grup kırılımı. Uygulamada bir prim/komisyon sistemi yok.
class TrainerReportPanel extends ConsumerWidget {
  const TrainerReportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final report = ref.watch(trainerReportControllerProvider);
    final soloLabel = ref.watch(
      rcTextProvider(RemoteConfigKeys.trainersReportOneOnOneToggle),
    );
    final groupLabel = ref.watch(
      rcTextProvider(RemoteConfigKeys.trainersReportGroupToggle),
    );

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

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.value});

  final String label;
  final String value;

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
            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
          ),
          Text(
            value,
            style: typography.headingSmall.copyWith(
              color: colors.onSurface,
              fontSize: 15,
            ),
          ),
        ],
      ),
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
