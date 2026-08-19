import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/admin_trainer_detail_controller.dart';
import '../../controller/trainer_report_controller.dart';
import '../../domain/admin_trainer_detail_stats.dart';
import '../../domain/admin_trainer_summary.dart';

/// Admin 4 · Antrenör Detayı — [AdminTrainerManagementPanel]'deki listeden
/// bir antrenöre dokununca açılır, tüm zamanlı ve bu ayki seans
/// istatistiklerini gösterir.
class AdminTrainerDetailPanel extends BasePanel {
  const AdminTrainerDetailPanel({required this.trainer, super.key});

  final AdminTrainerSummary trainer;

  @override
  ConsumerState<AdminTrainerDetailPanel> createState() =>
      _AdminTrainerDetailPanelState();
}

class _AdminTrainerDetailPanelState
    extends BasePanelState<AdminTrainerDetailPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final trainer = widget.trainer;
    final stats =
        ref.watch(adminTrainerDetailStatsProvider(trainer.id)).valueOrNull ??
        AdminTrainerDetailStats.empty;
    final monthly = ref.watch(reportForTrainerProvider(trainer.id));

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
                    'Antrenör detayı',
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
                    child: Row(
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
                            trainer.initials,
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
                                trainer.name,
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                trainer.phone.isEmpty
                                    ? '—'
                                    : formatTrPhoneDisplay(trainer.phone),
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                              ),
                              if (trainer.specialties.isNotEmpty)
                                Text(
                                  trainer.specialties.join(', '),
                                  style: typography.bodyMedium.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              Text(
                                '${trainer.memberCount} üye',
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
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
                    'TÜM ZAMANLAR',
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
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Toplam',
                            value: '${stats.totalSessions}',
                            valueColor: colors.onSurface,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Tamamlanan',
                            value: '${stats.completedSessions}',
                            valueColor: colors.success,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'Planlanan',
                            value: '${stats.plannedSessions}',
                            valueColor: colors.primary,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: 'İptal',
                            value: '${stats.cancelledSessions}',
                            valueColor: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'BU AY',
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
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: monthly.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => Text(
                        'Bu ayın verileri yüklenemedi.',
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                      data: (report) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < report.breakdown.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i < report.breakdown.length - 1
                                    ? AppSpacing.sm
                                    : 0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      report.breakdown[i].title,
                                      style: typography.bodyLarge.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${report.breakdown[i].total}',
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
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

class _StatTile extends StatelessWidget {
  const _StatTile({
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
    return Column(
      children: [
        Text(
          value,
          style: typography.dataLarge.copyWith(color: valueColor, fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: typography.caption.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}
