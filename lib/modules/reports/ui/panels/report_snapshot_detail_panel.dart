import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../domain/report_snapshot.dart';
import '../widgets/report_finance_summary_card.dart';
import '../widgets/report_metric_card.dart';
import '../widgets/report_trainer_performance_chart.dart';

/// F5-9 — geçmiş bir haftalık/aylık rapor snapshot'ının (F5-7/F5-8) detayı.
/// Canlı aggregation yapmaz — [snapshot] listeden zaten yüklenmiş halde
/// gelir, panel sadece F5-1'deki aynı widget'larla (metrik kartları, ciro/
/// gider/net, antrenör chart'ı) render eder.
class ReportSnapshotDetailPanel extends BasePanel {
  const ReportSnapshotDetailPanel({required this.snapshot, super.key});

  final ReportSnapshot snapshot;

  @override
  ConsumerState<ReportSnapshotDetailPanel> createState() =>
      _ReportSnapshotDetailPanelState();
}

class _ReportSnapshotDetailPanelState
    extends BasePanelState<ReportSnapshotDetailPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final report = widget.snapshot.report;

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
                      rcTextProvider(
                        RemoteConfigKeys.reportsSnapshotDetailTitle,
                      ),
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
                        child: ReportMetricCard(
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
                        child: ReportMetricCard(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAdminHomeCompletedLabel,
                            ),
                          ),
                          value: '${report.completedSessions}',
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: ReportMetricCard(
                          label: ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonIptalLabel),
                          ),
                          value: '${report.cancelledSessions}',
                          color: colors.error,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ReportFinanceSummaryCard(report: report),
                  const SizedBox(height: AppSpacing.lg),
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
                    child: ReportTrainerPerformanceChart(
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
