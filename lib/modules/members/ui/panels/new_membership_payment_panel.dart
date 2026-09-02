import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/money/app_money_formatter.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/admin_member_list_controller.dart';
import '../../controller/member_registration_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../controller/new_membership_controller.dart';
import '../widgets/installment_edit_sheet.dart';
import '../widgets/installment_row.dart';

/// Admin 7 · Yeni üyelik — Ödeme — toplam tutar taksitlere bölünür, her
/// taksit ayrı ayrı düzenlenip ödendi olarak işaretlenebilir.
class NewMembershipPaymentPanel extends BasePanel {
  const NewMembershipPaymentPanel({super.key});

  @override
  ConsumerState<NewMembershipPaymentPanel> createState() =>
      _NewMembershipPaymentPanelState();
}

class _NewMembershipPaymentPanelState
    extends BasePanelState<NewMembershipPaymentPanel> {
  late final TextEditingController _totalController;
  late final TextEditingController _countController;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController();
    _countController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final memberForm = ref.watch(newMemberControllerProvider);
    final membership = ref.watch(newMembershipControllerProvider);
    final membershipController = ref.read(
      newMembershipControllerProvider.notifier,
    );
    final package = membership.selectedPackage;

    if (!_hydrated && membership.totalAmountTl > 0) {
      _hydrated = true;
      _totalController.text = formatAmountGrouped(
        membership.totalAmountTl,
        ref.read(localeControllerProvider),
      );
      _countController.text = '${membership.installments.length}';
    }

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
                    children: [
                      AppBackButton(
                        onTap: () => ref
                            .read(panelStackControllerProvider.notifier)
                            .pop(),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        ref.watch(
                          rcTextProvider(RemoteConfigKeys.membersPaymentTitle),
                        ),
                        style: typography.headingSmall.copyWith(
                          color: colors.onSurface,
                          fontSize: 18,
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
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        ref.watch(
                          rcTextProvider(
                            RemoteConfigKeys.membersPaymentStepIndicator3,
                          ),
                        ),
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
                                package?.name ?? '',
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersPaymentTotalLabel,
                            ),
                          ),
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            AppMoneyInputFormatter(
                              locale: ref.watch(localeControllerProvider),
                            ),
                          ],
                          onChanged: (value) {
                            membershipController.setTotalAmount(
                              parseMoneyInput(
                                value,
                                ref.read(localeControllerProvider),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .membersPaymentInstallmentCountLabel,
                                  ),
                                ),
                                style: typography.bodyLarge.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.remove,
                              onTap: () {
                                final next = membership.installments.length - 1;
                                if (next < 1) return;
                                membershipController.setInstallmentCount(next);
                                _countController.text = '$next';
                              },
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            SizedBox(
                              width: 36,
                              child: TextField(
                                controller: _countController,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: typography.dataMedium.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                ),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) {
                                  final parsed = int.tryParse(value);
                                  if (parsed != null && parsed >= 1) {
                                    membershipController.setInstallmentCount(
                                      parsed,
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            _StepButton(
                              icon: Icons.add,
                              filled: true,
                              onTap: () {
                                final next = membership.installments.length + 1;
                                if (next > 12) return;
                                membershipController.setInstallmentCount(next);
                                _countController.text = '$next';
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(color: colors.outline, height: 1),
                        for (var i = 0; i < membership.installments.length; i++)
                          InstallmentRow(
                            installment: membership.installments[i],
                            showDivider: i < membership.installments.length - 1,
                            onTap: () => showInstallmentEditSheet(
                              context,
                              installment: membership.installments[i],
                              onSave:
                                  ({
                                    required amountTl,
                                    required dueDate,
                                    required paid,
                                  }) {
                                    membershipController.updateInstallment(
                                      membership.installments[i].index,
                                      amountTl: amountTl,
                                      dueDate: dueDate,
                                      paid: paid,
                                    );
                                    _totalController.text = formatAmountGrouped(
                                      ref
                                          .read(newMembershipControllerProvider)
                                          .totalAmountTl,
                                      ref.read(localeControllerProvider),
                                    );
                                  },
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.membersPaymentInstallmentNote,
                      ),
                    ),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (membership.errorMessage != null) ...[
                    Text(
                      membership.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: membership.isSaving
                        ? ref.watch(
                            rcTextProvider(RemoteConfigKeys.membersSavingLabel),
                          )
                        : ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonKaydet),
                          ),
                    onPressed: package == null || membership.isSaving
                        ? null
                        : () async {
                            final registration = ref.read(
                              memberRegistrationControllerProvider,
                            );
                            final memberId = registration.createdMemberId;
                            if (memberId == null) return;
                            if (!await ensureSubscriptionAllowsWrite(
                              context,
                              ref,
                            )) {
                              return;
                            }
                            final isRenewal = registration.isRenewal;
                            final success = await membershipController.save(
                              memberId,
                            );
                            if (!success || !mounted) return;
                            ref
                                .read(newMemberControllerProvider.notifier)
                                .reset();
                            ref
                                .read(newMembershipControllerProvider.notifier)
                                .reset();
                            ref
                                .read(
                                  memberRegistrationControllerProvider.notifier,
                                )
                                .reset();
                            // F7-2 — AdminMemberListController artık canlı dinlemiyor
                            // (sayfalı), yeni üyenin listede görünmesi için elle yenile.
                            unawaited(
                              ref
                                  .read(
                                    adminMemberListControllerProvider.notifier,
                                  )
                                  .refresh(),
                            );
                            final panelStack = ref.read(
                              panelStackControllerProvider.notifier,
                            );
                            if (isRenewal) {
                              // F5-17 — 1. adım hiç eklenmemişti: bu adım +
                              // paket adımını kapatmak üye detayına döner.
                              panelStack.pop();
                              panelStack.pop();
                            } else {
                              panelStack.popToRoot();
                            }
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _totalController.dispose();
    _countController.dispose();
    super.dispose();
  }
}

String _initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.take(2).map((w) => w[0]).join().toUpperCase();
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
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: filled ? colors.onPrimary : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
