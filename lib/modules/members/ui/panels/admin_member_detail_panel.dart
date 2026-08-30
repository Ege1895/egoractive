import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/trend_bar_chart.dart';
import '../../../badges/controller/badges_controller.dart';
import '../../../badges/domain/badge_item.dart';
import '../../../measurements/ui/panels/measurements_panel.dart';
import '../../../trainers/domain/trainer_member_detail.dart';
import '../../../trainers/domain/trainer_metric.dart';
import '../../controller/admin_member_detail_controller.dart';
import '../../controller/member_registration_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../controller/new_membership_controller.dart';
import '../../domain/admin_member_detail.dart';
import '../../domain/admin_member_summary.dart';
import '../widgets/installment_row.dart';
import 'edit_member_payment_panel.dart';
import 'member_info_panel.dart';
import 'new_membership_package_panel.dart';

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
  void _showMetricPicker(
    BuildContext context,
    TrainerMetric selected,
    ValueChanged<TrainerMetric> onSelect,
  ) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.lg,
            AppSpacing.screenEdge,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.outlineStrong,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final metric in TrainerMetric.values)
                _MetricPickerRow(
                  label: ref.watch(rcTextProvider(metric.rcKey)),
                  selected: metric == selected,
                  onTap: () {
                    onSelect(metric);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// F5-17 — "Paketi Yenile": Yeni Üyelik sihirbazının 1. adımını (üye
  /// bilgileri, bu üye zaten var) atlayıp doğrudan 2. adıma (paket seçimi)
  /// geçer. Başlık kartında görünsün diye ad/soyad ve antrenör adı önceden
  /// dolduruluyor — bunlar sadece görüntü amaçlı, yazma anında kullanılan
  /// tek şey `memberId` (`MemberRegistrationController.beginRenewal`).
  void _startRenewal(AdminMemberDetail detail) {
    final nameParts = detail.name.trim().split(RegExp(r'\s+'));
    final firstName = nameParts.isEmpty ? '' : nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    final newMemberController = ref.read(newMemberControllerProvider.notifier)
      ..reset()
      ..updateFirstName(firstName)
      ..updateLastName(lastName);
    newMemberController.selectTrainer('', detail.trainerName);
    ref.read(newMembershipControllerProvider.notifier).reset();
    ref
        .read(memberRegistrationControllerProvider.notifier)
        .beginRenewal(widget.memberId);
    ref
        .read(panelStackControllerProvider.notifier)
        .push(const NewMembershipPackagePanel());
  }

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
    // F5-17 renewal fix — `newMemberControllerProvider`/
    // `memberRegistrationControllerProvider` autoDispose: normal Yeni Üyelik
    // akışında 1. adım ekranı (MemberInfoPanel) bunları sürekli izleyip
    // stack'te kaldığı için canlı kalıyorlar. "Paketi Yenile" 1. adımı
    // atladığından, bu paneli (sihirbaz boyunca stack'te tek kalıcı ekran)
    // izleyici olarak tutmazsak `_startRenewal`'in yazdığı isim/`memberId`
    // değerleri, 2. adım ekranı ilk kez izlemeye başlamadan önceki kısa
    // boşlukta siliniyordu (ad "?" avatarına dönüyor, Kaydet sessizce hiçbir
    // şey yapmıyordu — memberId null'a düştüğü için).
    ref.watch(newMemberControllerProvider);
    ref.watch(memberRegistrationControllerProvider);

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
                  ref.watch(
                    rcTextProvider(RemoteConfigKeys.membersDetailNotFound),
                  ),
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
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.commonUyeDetayiTitle),
                      ),
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
                                  // MemberInfoPanel edit modunda kullanılmıyor
                                  // (sadece id/isim/telefon okunuyor), gerçek
                                  // bir değer gerekmiyor.
                                  unplannedSessions: detail.remainingSessions,
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
                          ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonDuzenle),
                          ),
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
                                    ref
                                        .watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .membersDetailPhoneTrainerLine,
                                          ),
                                        )
                                        .replaceAll(
                                          '{phone}',
                                          formatTrPhoneDisplay(detail.phone),
                                        )
                                        .replaceAll(
                                          '{trainerName}',
                                          detail.trainerName,
                                        ),
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
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .membersDetailRemainingSessionsLabel,
                                  ),
                                ),
                                value: '${detail.remainingSessions}',
                                valueColor: colors.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatTile(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersDetailMakeupLabel,
                                  ),
                                ),
                                value: '${detail.makeupSessions}',
                                valueColor: colors.onSurface,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StatTile(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonBitisLabel,
                                  ),
                                ),
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
                                    ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .membersDetailPaymentStatusLabel,
                                      ),
                                    ),
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onWarningContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  ref
                                      .watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .membersDetailLastPaymentLabel,
                                        ),
                                      )
                                      .replaceAll(
                                        '{date}',
                                        detail.lastPaymentDate,
                                      ),
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
                                    label: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .membersDetailTotalLabel,
                                      ),
                                    ),
                                    value: '₺${detail.paymentTotalTl}',
                                    valueColor: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _PaymentTile(
                                    label: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys.membersDetailPaidLabel,
                                      ),
                                    ),
                                    value: '₺${detail.paymentPaidTl}',
                                    valueColor: colors.success,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: _PaymentTile(
                                    label: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .membersDetailRemainingAmountLabel,
                                      ),
                                    ),
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
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.membersDetailRenewPackageButton,
                      ),
                    ),
                    variant: AppButtonVariant.secondary,
                    onPressed: detail.paymentDueTl > 0
                        ? null
                        : () => _startRenewal(detail),
                  ),
                  if (detail.paymentDueTl > 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.membersDetailRenewPackageBlockedNote,
                        ),
                      ),
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.membersDetailBadgesSectionHeader,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MemberBadgesRow(memberId: widget.memberId),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.membersDetailViewMeasurementsButton,
                      ),
                    ),
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
                    onTap: () => _showMetricPicker(
                      context,
                      detail.selectedMetric,
                      controller.selectMetric,
                    ),
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
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .commonOlcum6AySectionHeader,
                                  ),
                                ),
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                ref.watch(
                                  rcTextProvider(detail.selectedMetric.rcKey),
                                ),
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.keyboard_arrow_down,
                            color: colors.onPrimaryContainer,
                          ),
                        ],
                      ),
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
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.commonDersGecmisiSectionHeader,
                      ),
                    ),
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

class _MemberBadgesRow extends ConsumerWidget {
  const _MemberBadgesRow({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final badges = ref.watch(memberBadgesProvider(memberId)).valueOrNull;
    if (badges == null) {
      return SizedBox(
        height: 64,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(colors.onSurfaceMuted),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => _MemberBadgeCircle(
          badge: badges[index],
          onTap: () => _showBadgeDetail(context, ref, badges[index]),
        ),
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, WidgetRef ref, BadgeItem badge) {
    final colors = context.appColors;
    final typography = context.appTypography;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.lg,
            AppSpacing.screenEdge,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _BadgeIcon(badge: badge, size: 56, iconSize: 24),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge.title,
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          badge.earned
                              ? ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.badgesDetailEarnedStatus,
                                  ),
                                )
                              : ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.badgesDetailLockedStatus,
                                  ),
                                ),
                          style: typography.bodyMedium.copyWith(
                            color: badge.earned
                                ? colors.success
                                : colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                badge.note,
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MemberBadgeCircle extends StatelessWidget {
  const _MemberBadgeCircle({required this.badge, required this.onTap});

  final BadgeItem badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      onTap: onTap,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BadgeIcon(badge: badge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              badge.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: typography.caption.copyWith(
                fontSize: 10,
                color: badge.earned ? colors.onSurface : colors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.badge, this.size = 44, this.iconSize = 18});

  final BadgeItem badge;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final earned = badge.earned;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: earned ? colors.primary : colors.outlineStrong,
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Opacity(
          // Kazanılmamış rozet kilit ikonu yerine SOLUK gösteriliyor —
          // kazanılan canlı/tam opaklıkta (bkz. badges_panel.dart'taki aynı
          // desen).
          opacity: earned ? 1 : 0.35,
          child: Image.asset(
            'assets/badges/${badge.id}.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: earned ? colors.primaryContainer : colors.surfaceRaised,
              alignment: Alignment.center,
              child: Icon(
                earned ? Icons.emoji_events : Icons.lock_outline,
                size: iconSize,
                color: earned ? colors.primary : colors.onSurfaceMuted,
              ),
            ),
          ),
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

class _MetricPickerRow extends StatelessWidget {
  const _MetricPickerRow({
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
    final typography = context.appTypography;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: colors.primary, size: 20),
          ],
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
