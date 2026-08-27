import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/dashboard_report_controller.dart';
import '../../controller/report_snapshot_controller.dart';
import '../../domain/report_snapshot.dart';
import '../widgets/report_finance_summary_card.dart';
import '../widgets/report_metric_card.dart';
import '../widgets/report_trainer_performance_chart.dart';
import 'report_snapshot_detail_panel.dart';

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
                              child: ReportMetricCard(
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
                        ReportFinanceSummaryCard(report: report),
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
                              : ReportTrainerPerformanceChart(
                                  trainerPerformance: report.trainerPerformance,
                                ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _PastReportsSection(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // `PanelStackController` panelleri hiç dispose etmiyor (`Visibility`
  // `maintainState: true`) — admin bir üyenin ödeme durumunu değiştirip bu
  // ekrana geri döndüğünde, altta yatan `autoDispose` provider'lar hâlâ
  // izlendiği için (bu ekran gizliyken bile) hiç yeniden çekilmiyor,
  // Raporlar eski/"cache'de kalmış" görünüyordu. Ekran her ön plana
  // geldiğinde canlı özeti ve geçmiş rapor listesini elle tazeliyoruz.
  @override
  void onPanelShow() {
    ref.read(dashboardReportControllerProvider.notifier).retry();
    ref.read(reportSnapshotControllerProvider.notifier).retry();
  }
}

/// F5-9 — haftalık/aylık filtre + geçmiş `reportSnapshots` listesi. Bir
/// öğeye dokununca [ReportSnapshotDetailPanel] o snapshot'ın verisiyle
/// (canlı aggregation değil) açılır.
class _PastReportsSection extends ConsumerWidget {
  const _PastReportsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final selectedPeriod = ref.watch(reportSnapshotControllerProvider);
    final controller = ref.watch(reportSnapshotControllerProvider.notifier);
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    // F5-20 fix — bu widget'ın KENDİSİ izlemeli (bkz.
    // report_snapshot_controller.dart'taki not): veri yüklenip bittiğinde
    // bu widget'ı gerçekten tetikleyen tek yol bu.
    final snapshotsAsync = gymId == null
        ? const AsyncValue<List<ReportSnapshot>>.data(<ReportSnapshot>[])
        : ref.watch(reportSnapshotsForGymProvider(gymId, selectedPeriod));
    final snapshots = snapshotsAsync.valueOrNull ?? const [];
    final isLoading = snapshotsAsync.isLoading;
    final hasError = snapshotsAsync.hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ref.watch(
            rcTextProvider(RemoteConfigKeys.reportsPastReportsSectionTitle),
          ),
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(color: colors.outline),
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
          ),
          child: Row(
            children: [
              Expanded(
                child: _PeriodToggleTab(
                  label: ref.watch(
                    rcTextProvider(RemoteConfigKeys.reportsPeriodWeeklyLabel),
                  ),
                  selected: selectedPeriod == ReportPeriod.weekly,
                  onTap: () => controller.selectPeriod(ReportPeriod.weekly),
                ),
              ),
              Expanded(
                child: _PeriodToggleTab(
                  label: ref.watch(
                    rcTextProvider(RemoteConfigKeys.reportsPeriodMonthlyLabel),
                  ),
                  selected: selectedPeriod == ReportPeriod.monthly,
                  onTap: () => controller.selectPeriod(ReportPeriod.monthly),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (isLoading && snapshots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (hasError)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Column(
              children: [
                Text(
                  ref.watch(
                    rcTextProvider(
                      RemoteConfigKeys.reportsSnapshotListLoadError,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: controller.retry,
                  child: Text(
                    ref.watch(rcTextProvider(RemoteConfigKeys.authRetryButton)),
                  ),
                ),
              ],
            ),
          )
        else if (snapshots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Text(
              ref.watch(
                rcTextProvider(RemoteConfigKeys.reportsSnapshotListEmptyState),
              ),
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
              ),
            ),
          )
        else
          Column(
            children: [
              for (final snapshot in snapshots)
                _PastReportListTile(snapshot: snapshot),
            ],
          ),
      ],
    );
  }
}

class _PeriodToggleTab extends StatelessWidget {
  const _PeriodToggleTab({
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
      color: selected ? colors.surfaceRaised : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _PastReportListTile extends ConsumerWidget {
  const _PastReportListTile({required this.snapshot});

  final ReportSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          onTap: () => ref
              .read(panelStackControllerProvider.notifier)
              .push(ReportSnapshotDetailPanel(snapshot: snapshot)),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    snapshot.report.monthLabel,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
