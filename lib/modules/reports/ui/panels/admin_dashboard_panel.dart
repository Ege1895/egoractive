import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/dashboard_report_controller.dart';
import '../../domain/dashboard_report.dart';

/// Admin · Raporlar — aylık seans/ciro/gider özeti + antrenör performansı
/// (F5-1). Sayımlar Firestore `count()`/`sum()` aggregation query'leriyle
/// hesaplanır, hiçbir yerde tüm seans dokümanları client'a çekilmez —
/// 10.000+ kayıtlı bir salonda da hızlı yüklenir. F7-2 — antrenör dökümü
/// (çok antrenörlü salonlarda asıl maliyeti taşıyan kısım) özetten ayrı
/// yüklenir; özet metrikler antrenör dökümünü beklemeden görünür, antrenör
/// bölümü kendi yükleniyor göstergesini ayrı gösterir.
class AdminDashboardPanel extends BasePanel {
  const AdminDashboardPanel({super.key});

  @override
  ConsumerState<AdminDashboardPanel> createState() =>
      _AdminDashboardPanelState();
}

class _AdminDashboardPanelState extends BasePanelState<AdminDashboardPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final report = ref.watch(dashboardReportControllerProvider);
    final controller = ref.watch(dashboardReportControllerProvider.notifier);
    final isSummaryLoading = controller.isSummaryLoading;
    final isTrainerPerformanceLoading = controller.isTrainerPerformanceLoading;
    final hasSummaryError = controller.hasSummaryError;
    final hasTrainerPerformanceError = controller.hasTrainerPerformanceError;

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
                      rcTextProvider(RemoteConfigKeys.gymsSettingsNavReports),
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
              child: isSummaryLoading
                  ? Center(
                      child: CircularProgressIndicator(color: colors.primary),
                    )
                  : hasSummaryError
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenEdge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.reportsSummaryLoadError,
                                ),
                              ),
                              textAlign: TextAlign.center,
                              style: typography.bodyMedium.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextButton(
                              onPressed: controller.retry,
                              child: Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.authRetryButton,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenEdge,
                        AppSpacing.md,
                        AppSpacing.screenEdge,
                        AppSpacing.lg,
                      ),
                      children: [
                        Text(
                          report.monthLabel,
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.reportsTotalSessionsLabel,
                                  ),
                                ),
                                value: '${report.totalSessions}',
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _MetricCard(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .gymsAdminHomeCompletedLabel,
                                  ),
                                ),
                                value: '${report.completedSessions}',
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _MetricCard(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonIptalLabel,
                                  ),
                                ),
                                value: '${report.cancelledSessions}',
                                color: colors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusCard,
                            ),
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
                                          RemoteConfigKeys
                                              .gymsAdminHomeEstimatedRevenueLabel,
                                        ),
                                      ),
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                    Text(
                                      '₺${report.estimatedRevenueTl}',
                                      style: typography.headingMedium.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .gymsAdminHomeExpenseLabel,
                                        ),
                                      ),
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                    Text(
                                      '₺${report.totalExpensesTl}',
                                      style: typography.headingMedium.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys.reportsNetLabel,
                                        ),
                                      ),
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                    Text(
                                      '₺${report.netTl}',
                                      style: typography.headingMedium.copyWith(
                                        color: report.netTl >= 0
                                            ? colors.primary
                                            : colors.error,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsAdminHomeTrainerPerformanceSection,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.sm,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusCard,
                            ),
                            border: Border.all(color: colors.outline),
                          ),
                          child:
                              isTrainerPerformanceLoading &&
                                  report.trainerPerformance.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : hasTrainerPerformanceError
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        ref.watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .reportsTrainerPerformanceLoadError,
                                          ),
                                        ),
                                        style: typography.bodyMedium.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      TextButton(
                                        onPressed: controller.retry,
                                        child: Text(
                                          ref.watch(
                                            rcTextProvider(
                                              RemoteConfigKeys.authRetryButton,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : report.trainerPerformance.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                  child: Text(
                                    ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .reportsTrainerPerformanceEmptyState,
                                      ),
                                    ),
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                    ),
                                  ),
                                )
                              : _TrainerPerformanceChart(
                                  trainerPerformance: report.trainerPerformance,
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

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: typography.headingMedium.copyWith(
              color: color,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainerPerformanceChart extends StatelessWidget {
  const _TrainerPerformanceChart({required this.trainerPerformance});

  final List<TrainerPerformance> trainerPerformance;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final maxCompleted = trainerPerformance
        .map((t) => t.completedSessions)
        .fold(0, (a, b) => a > b ? a : b);
    final chartMax = (maxCompleted == 0 ? 1 : maxCompleted).toDouble() * 1.25;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= trainerPerformance.length) {
                    return const SizedBox.shrink();
                  }
                  final name = trainerPerformance[index].name;
                  final shortName = name.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      shortName,
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < trainerPerformance.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: trainerPerformance[i].completedSessions.toDouble(),
                    color: colors.primary,
                    width: 22,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
