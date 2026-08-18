import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../packages/controller/studio_packages_controller.dart';
import '../../../packages/domain/studio_package.dart';
import '../../controller/new_member_controller.dart';
import '../../controller/new_membership_controller.dart';
import 'new_membership_payment_panel.dart';

const _monthAbbrev = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

String _formatDate(DateTime date) =>
    '${date.day} ${_monthAbbrev[date.month]} ${date.year}';

/// Admin 6 · Yeni üyelik — Paket — paket seçince alanlar otomatik dolar.
class NewMembershipPackagePanel extends BasePanel {
  const NewMembershipPackagePanel({super.key});

  @override
  ConsumerState<NewMembershipPackagePanel> createState() =>
      _NewMembershipPackagePanelState();
}

class _NewMembershipPackagePanelState
    extends BasePanelState<NewMembershipPackagePanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final memberForm = ref.watch(newMemberControllerProvider);
    final packages = ref
        .watch(studioPackagesControllerProvider)
        .where((p) => p.activeForSale)
        .toList();
    final membership = ref.watch(newMembershipControllerProvider);
    final membershipController = ref.read(
      newMembershipControllerProvider.notifier,
    );

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yeni üyelik',
                        style: typography.headingSmall.copyWith(
                          color: colors.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref
                            .read(panelStackControllerProvider.notifier)
                            .popToRoot(),
                        child: Text(
                          'Vazgeç',
                          style: typography.bodyLarge.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '2 / 3',
                        style: typography.headingSmall.copyWith(
                          fontSize: 13,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initialsOf(
                              '${memberForm.firstName} ${memberForm.lastName}',
                            ),
                            style: typography.headingSmall.copyWith(
                              color: colors.onPrimaryContainer,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${memberForm.firstName} ${memberForm.lastName}'
                                    .trim(),
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Antrenör: ${memberForm.trainerName}',
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 13,
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
                    'PAKET SEÇ',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final package in packages)
                    _PackagePick(
                      package: package,
                      selected: membership.selectedPackage?.id == package.id,
                      onTap: () => membershipController.selectPackage(package),
                    ),
                  const SizedBox(height: AppSpacing.md),
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
                        _InfoRow(
                          label: 'Başlangıç tarihi',
                          value: _formatDate(membership.startDate),
                          showDivider: true,
                        ),
                        _InfoRow(
                          label: 'Bitiş tarihi',
                          value: _formatDate(membership.endDate),
                          showDivider: true,
                        ),
                        _InfoRow(
                          label: 'Seans sayısı',
                          value:
                              '${membership.selectedPackage?.sessionCount ?? 0}',
                          showDivider: true,
                        ),
                        Container(
                          constraints: const BoxConstraints(minHeight: 56),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Telafi seans sayısı',
                                      style: typography.bodyLarge.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Paket bitince kullanılabilir',
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _StepButton(
                                icon: Icons.remove,
                                onTap: membershipController.decrementMakeup,
                              ),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${membership.makeupSessions}',
                                  textAlign: TextAlign.center,
                                  style: typography.dataMedium.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              _StepButton(
                                icon: Icons.add,
                                filled: true,
                                onTap: membershipController.incrementMakeup,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bitiş tarihi ve seans sayısı seçtiğiniz pakete göre dolar; isterseniz elle değiştirebilirsiniz.',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Ödeme bilgisine geç',
                onPressed: membership.selectedPackage == null
                    ? null
                    : () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(const NewMembershipPaymentPanel()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}

class _PackagePick extends StatelessWidget {
  const _PackagePick({
    required this.package,
    required this.selected,
    required this.onTap,
  });

  final StudioPackage package;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outlineStrong,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${package.sessionType.label} · ${package.validityDays} gün',
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₺${package.priceTl}',
                style: typography.headingSmall.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.showDivider,
  });

  final String label;
  final String value;
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: typography.bodyLarge.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: typography.headingSmall.copyWith(
                color: colors.onSurface,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: filled ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: filled ? colors.onPrimary : colors.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }
}
