import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../gyms/controller/gym_profile_controller.dart';
import '../../domain/report_snapshot.dart';
import '../../service/report_pdf_export_service.dart';
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
  bool _isExporting = false;

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
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.reportsExportPdfButtonLabel,
                      ),
                    ),
                    variant: AppButtonVariant.secondary,
                    onPressed: _isExporting ? null : _exportPdf,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    final labels = ReportPdfLabels(
      documentTitle: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfDocumentTitle),
      ),
      heroPositiveTemplate: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfHeroPositiveTemplate),
      ),
      heroNegativeTemplate: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfHeroNegativeTemplate),
      ),
      heroSubPositive: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfHeroSubPositive),
      ),
      heroSubNegative: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfHeroSubNegative),
      ),
      sessionsTitle: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfSessionsTitle),
      ),
      totalSessions: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsTotalSessionsLabel),
      ),
      completed: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsAdminHomeCompletedLabel),
      ),
      cancelled: ref.read(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
      other: ref.read(rcTextProvider(RemoteConfigKeys.reportsPdfOtherLabel)),
      groupEventsTitle: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfGroupEventsTitle),
      ),
      groupSessionsLabel: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfGroupSessionsLabel),
      ),
      eventsLabel: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfEventsLabel),
      ),
      sessionsUnit: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfSessionsUnit),
      ),
      eventsUnit: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfEventsUnit),
      ),
      attendanceTemplate: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfAttendanceTemplate),
      ),
      trainersTitle: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsAdminHomeTrainerPerformanceSection),
      ),
      trainersEmpty: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsTrainerPerformanceEmptyState),
      ),
      completedShort: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfCompletedShortLabel),
      ),
      cancelledShort: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfCancelledShortLabel),
      ),
      totalShort: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfTotalShortLabel),
      ),
      completionRateTemplate: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfCompletionRateTemplate),
      ),
      packagesTitle: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfPackagesTitle),
      ),
      packagesEmpty: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfPackagesEmpty),
      ),
      salesUnit: ref.read(rcTextProvider(RemoteConfigKeys.reportsPdfSalesUnit)),
      financeTitle: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfFinanceTitle),
      ),
      revenue: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsAdminHomeEstimatedRevenueLabel),
      ),
      expenses: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsAdminHomeExpenseLabel),
      ),
      netProfit: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfNetProfitLabel),
      ),
      netLoss: ref.read(
        rcTextProvider(RemoteConfigKeys.reportsPdfNetLossLabel),
      ),
      footer: ref.read(rcTextProvider(RemoteConfigKeys.reportsPdfFooter)),
    );
    final gymName = ref.read(gymProfileControllerProvider).name;

    try {
      await ref
          .read(reportPdfExportServiceProvider)
          .share(widget.snapshot, gymName, labels);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(rcTextProvider(RemoteConfigKeys.reportsPdfExportError)),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }
}
