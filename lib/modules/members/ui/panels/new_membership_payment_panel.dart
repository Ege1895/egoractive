import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/admin_member_list_controller.dart';
import '../../controller/member_registration_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../controller/new_membership_controller.dart';

/// Admin 7 · Yeni üyelik — Ödeme — ödeme çipleri kalan tutarı hesaplar.
class NewMembershipPaymentPanel extends BasePanel {
  const NewMembershipPaymentPanel({super.key});

  @override
  ConsumerState<NewMembershipPaymentPanel> createState() => _NewMembershipPaymentPanelState();
}

class _NewMembershipPaymentPanelState extends BasePanelState<NewMembershipPaymentPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final memberForm = ref.watch(newMemberControllerProvider);
    final membership = ref.watch(newMembershipControllerProvider);
    final membershipController = ref.read(newMembershipControllerProvider.notifier);
    final package = membership.selectedPackage;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
                      const SizedBox(width: AppSpacing.md),
                      Text('Ödeme bilgisi', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(child: Container(height: 5, decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)))),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Container(height: 5, decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)))),
                      const SizedBox(width: AppSpacing.sm),
                      Text('3 / 3', style: typography.headingSmall.copyWith(fontSize: 13, color: colors.onPrimaryContainer)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            _initialsOf('${memberForm.firstName} ${memberForm.lastName}'),
                            style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${memberForm.firstName} ${memberForm.lastName}'.trim(), style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                              Text(package?.name ?? '', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
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
                          children: [
                            Expanded(
                              child: Text('Toplam tutar', style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
                            ),
                            Text('₺${membership.totalAmount}', style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 22)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(color: colors.outline, height: 1),
                        const SizedBox(height: AppSpacing.md),
                        Text('Ödendi', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: _PayChip(
                                label: 'Tam ödendi',
                                amount: '₺${membership.totalAmount}',
                                selected: membership.paidAmount == membership.totalAmount,
                                onTap: membershipController.setPaidFull,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _PayChip(
                                label: 'Yarısı',
                                amount: '₺${(membership.totalAmount / 2).round()}',
                                selected: membership.paidAmount == (membership.totalAmount / 2).round() && membership.paidAmount != 0,
                                onTap: membershipController.setPaidHalf,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _PayChip(
                                label: 'Diğer',
                                amount: '₺${membership.paidAmount}',
                                selected: membership.paidAmount != membership.totalAmount && membership.paidAmount != (membership.totalAmount / 2).round(),
                                onTap: () => _showOtherAmountSheet(context, membershipController, membership.totalAmount),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: membership.isFullyPaid ? colors.successContainer : colors.warningContainer,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            border: Border.all(color: (membership.isFullyPaid ? colors.success : colors.warning).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Kalan ödeme', style: typography.caption.copyWith(color: membership.isFullyPaid ? colors.onSuccessContainer : colors.onWarningContainer)),
                                    Text('Otomatik hesaplanır', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(
                                '₺${membership.dueAmount}',
                                style: typography.dataLarge.copyWith(color: membership.isFullyPaid ? colors.onSuccessContainer : colors.onWarningContainer, fontSize: 24),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text('Son ödeme tarihi', style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
                            ),
                            Text(
                              membership.isFullyPaid ? '—' : '10 Ağu 2026',
                              style: typography.headingSmall.copyWith(color: membership.isFullyPaid ? colors.onSurfaceMuted : colors.onSurface, fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Üye kendi ekranında yalnızca kalan dersini ve paket bitişini görür; tutarlar üyeye gösterilmez.',
                    style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(
                label: 'Kaydet',
                onPressed: package == null
                    ? null
                    : () async {
                        final memberId = ref.read(memberRegistrationControllerProvider).createdMemberId;
                        if (memberId == null) return;
                        if (!await ensureSubscriptionAllowsWrite(context, ref)) return;
                        final success = await membershipController.save(memberId);
                        if (!success || !mounted) return;
                        ref.read(newMemberControllerProvider.notifier).reset();
                        ref.read(newMembershipControllerProvider.notifier).reset();
                        // F7-2 — AdminMemberListController artık canlı dinlemiyor
                        // (sayfalı), yeni üyenin listede görünmesi için elle yenile.
                        unawaited(ref.read(adminMemberListControllerProvider.notifier).refresh());
                        ref.read(panelStackControllerProvider.notifier).popToRoot();
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOtherAmountSheet(BuildContext context, NewMembershipController controller, int totalAmount) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final draftController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ödenen tutarı gir', style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 20)),
              const SizedBox(height: AppSpacing.xs),
              Text('Toplam ₺$totalAmount · kalan otomatik hesaplanır', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(controller: draftController, keyboardType: TextInputType.number, hint: '0'),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Kaydet',
                      onPressed: () {
                        controller.setPaidAmount(int.tryParse(draftController.text) ?? 0);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(label: 'Vazgeç', variant: AppButtonVariant.secondary, onPressed: () => Navigator.of(sheetContext).pop()),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

String _initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}

class _PayChip extends StatelessWidget {
  const _PayChip({required this.label, required this.amount, required this.selected, required this.onTap});

  final String label;
  final String amount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: typography.headingSmall.copyWith(fontSize: 14, color: selected ? colors.onPrimaryContainer : colors.onSurface)),
              Text(amount, style: typography.caption.copyWith(fontSize: 11, color: colors.onSurfaceMuted)),
            ],
          ),
        ),
      ),
    );
  }
}
