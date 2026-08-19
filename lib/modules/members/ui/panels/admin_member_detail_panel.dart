import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/trend_bar_chart.dart';
import '../../../measurements/ui/panels/measurements_panel.dart';
import '../../../trainers/domain/trainer_member_detail.dart';
import '../../../trainers/domain/trainer_metric.dart';
import '../../controller/admin_member_detail_controller.dart';
import '../../domain/admin_member_summary.dart';
import '../widgets/installment_row.dart';
import 'edit_member_payment_panel.dart';
import 'member_info_panel.dart';

/// Admin 21 · Üye Detayı — yönetici görünümü, ödeme bilgisi dahil.
class AdminMemberDetailPanel extends BasePanel {
  const AdminMemberDetailPanel({required this.memberId, super.key});

  final String memberId;

  @override
  ConsumerState<AdminMemberDetailPanel> createState() =>
      _AdminMemberDetailPanelState();
}

class _AdminMemberDetailPanelState
    extends BasePanelState<AdminMemberDetailPanel> {
  bool _metricPickerOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final detail = ref.watch(
      adminMemberDetailControllerProvider(widget.memberId),
    );
    final controller = ref.read(
      adminMemberDetailControllerProvider(widget.memberId).notifier,
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
                  'Üye bulunamadı.',
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
                  Expanded(
                    child: Text(
                      'Üye detayı',
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Material(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      onTap: () {
                        // `AdminMembersController` (global üye listesi) bu
                        // panele hiç bağlanmıyor — sadece Üyeler listesinden
                        // gelen `AdminMemberListController` bağlanıyor. O
                        // yüzden `Düzenle`'ye ilk dokunuşta stream henüz
                        // veri getirmemiş oluyor, arama boş listede
                        // başarısız olup sessizce hiçbir şey yapmıyordu.
                        // MemberInfoPanel edit modunda sadece id/isim/telefon
                        // kullanıyor — bunlar zaten yüklenmiş `detail`'da
                        // var, ayrı bir listeye bağımlı kalmaya gerek yok.
                        ref
                            .read(panelStackControllerProvider.notifier)
                            .push(
                              MemberInfoPanel(
                                existing: AdminMemberSummary(
                                  id: widget.memberId,
                                  initials: detail.initials,
                                  name: detail.name,
                                  phone: detail.phone,
                                  trainerName: '',
                                  remainingSessions: detail.remainingSessions,
                                  packageEndDate: detail.packageEndDate,
                                  status: MemberPackageStatus.none,
                                ),
                              ),
                            );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text(
                          'Düzenle',
                          style: typography.headingSmall.copyWith(
                            fontSize: 14,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
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
                                    '${formatTrPhoneDisplay(detail.phone)} · Antrenör: ${detail.trainerName}',
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
                              child: _StatTile(
                                label: 'Kalan ders',
                                value: '${detail.remainingSessions}',
                                valueColor: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatTile(
                                label: 'Telafi',
                                value: '${detail.makeupSessions}',
                                valueColor: colors.onSurface,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatTile(
                                label: 'Bitiş',
                                value: detail.packageEndDate,
                                valueColor: colors.onSurface,
                                small: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Material(
                    color: colors.warningContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(
                            EditMemberPaymentPanel(memberId: widget.memberId),
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          border: Border.all(
                            color: colors.warning.withValues(alpha: 0.32),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Ödeme durumu',
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onWarningContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Son ödeme ${detail.lastPaymentDate}',
                                  style: typography.bodyMedium.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Icon(
                                  Icons.chevron_right,
                                  color: colors.onSurfaceMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _PaymentTile(
                                    label: 'Toplam',
                                    value: '₺${detail.paymentTotalTl}',
                                    valueColor: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _PaymentTile(
                                    label: 'Ödendi',
                                    value: '₺${detail.paymentPaidTl}',
                                    valueColor: colors.success,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _PaymentTile(
                                    label: 'Kalan',
                                    value: '₺${detail.paymentDueTl}',
                                    valueColor: colors.onWarningContainer,
                                  ),
                                ),
                              ],
                            ),
                            if (detail.installments.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusInner,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    for (
                                      var i = 0;
                                      i < detail.installments.length;
                                      i++
                                    )
                                      InstallmentRow(
                                        installment: detail.installments[i],
                                        showDivider:
                                            i < detail.installments.length - 1,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: 'Ölçüm ekranını gör',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => ref
                        .read(panelStackControllerProvider.notifier)
                        .push(
                          MeasurementsPanel(
                            memberId: widget.memberId,
                            memberName: detail.name,
                          ),
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
                                'ÖLÇÜM · 6 AY',
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
                      valueFormatter: (v) =>
                          v.toStringAsFixed(1).replaceAll('.', ','),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'DERS GEÇMİŞİ',
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.valueColor,
    this.small = false,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool small;

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
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: small
                ? typography.headingSmall.copyWith(
                    color: valueColor,
                    fontSize: 15,
                  )
                : typography.headingMedium.copyWith(
                    color: valueColor,
                    fontSize: 22,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.background.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: typography.headingSmall.copyWith(
              color: valueColor,
              fontSize: 16,
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
        children: [
          Expanded(
            child: Column(
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
