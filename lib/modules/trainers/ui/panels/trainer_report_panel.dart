import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/trainer_report_controller.dart';
import '../../domain/trainer_report_state.dart';

/// Antrenör 2 · Seans Raporum (Raporum sekmesi kökü) — prim + Birebir/Grup
/// kırılımı. "Detay" ve "Prim sistemine git" bu fazda görsel, hedefsiz.
class TrainerReportPanel extends ConsumerWidget {
  const TrainerReportPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final report = ref.watch(trainerReportControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
          children: [
            Text('Seans raporum', style: typography.headingLarge.copyWith(color: colors.onSurface)),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(child: _DateTile(label: 'Başlangıç t.', value: report.startDate)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _DateTile(label: 'Bitiş t.', value: report.endDate)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.primary.withValues(alpha: 0.32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kazanılan prim', style: typography.bodyMedium.copyWith(color: colors.onPrimaryContainer, fontSize: 13)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(report.bonusAmount, style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 40)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${report.completedSessionCount} tamamlanan seans · seans başı ${report.perSessionRate}',
                    style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              alignment: Alignment.center,
                              child: Text('Detay', style: typography.headingSmall.copyWith(fontSize: 15, color: colors.onPrimary)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Material(
                          color: colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              alignment: Alignment.center,
                              child: Text(
                                'Prim sistemine git',
                                textAlign: TextAlign.center,
                                style: typography.headingSmall.copyWith(fontSize: 15, color: colors.onSurfaceVariant),
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
            for (final b in report.breakdown) ...[
              _BreakdownCard(breakdown: b),
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
          Text(label, style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
          Text(value, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.breakdown});

  final TrainerReportBreakdown breakdown;

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
                child: Text(breakdown.title, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${breakdown.total}',
                style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 28),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _MiniStat(label: 'Birebir', value: '${breakdown.solo}')),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: _MiniStat(label: 'Grup', value: '${breakdown.group}')),
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
      decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
          Text(value, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 17)),
        ],
      ),
    );
  }
}
