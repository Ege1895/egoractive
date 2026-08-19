import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/membership_installment.dart';
import '../../../../shared/utils/thousands_input_formatter.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/admin_member_detail_controller.dart';
import '../../domain/admin_member_detail.dart';
import '../widgets/installment_edit_sheet.dart';
import '../widgets/installment_row.dart';

/// Admin · Üye ödeme bilgileri düzenleme — [AdminMemberDetailPanel]'deki
/// "Ödeme durumu" kartına dokununca açılır. Eski üyeliklerde (F3-2 taksit
/// sistemi öncesi kaydedilmiş) hiç taksit yoksa, mevcut toplam/ödenen
/// tutardan tek taksitli bir plan türetilerek başlanır — admin oradan
/// taksit sayısını/tutarlarını istediği gibi değiştirebilir.
class EditMemberPaymentPanel extends BasePanel {
  const EditMemberPaymentPanel({required this.memberId, super.key});

  final String memberId;

  @override
  ConsumerState<EditMemberPaymentPanel> createState() =>
      _EditMemberPaymentPanelState();
}

class _EditMemberPaymentPanelState
    extends BasePanelState<EditMemberPaymentPanel> {
  late final TextEditingController _totalController;
  late final TextEditingController _countController;
  late int _totalAmountTl;
  late List<MembershipInstallment> _installments;
  bool _hydrated = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController();
    _countController = TextEditingController();
  }

  void _hydrate(AdminMemberDetail detail) {
    if (_hydrated) return;
    _hydrated = true;
    if (detail.installments.isNotEmpty) {
      _totalAmountTl = detail.paymentTotalTl;
      _installments = List.of(detail.installments);
    } else if (detail.paymentTotalTl > 0) {
      // Eski üyelik — taksit hiç girilmemiş, mevcut toplam/ödenen tutardan
      // tek taksitli bir başlangıç planı türetilir.
      _totalAmountTl = detail.paymentTotalTl;
      _installments = [
        MembershipInstallment(
          index: 1,
          amountTl: detail.paymentTotalTl,
          dueDate: DateTime.now(),
          paid: detail.paymentPaidTl >= detail.paymentTotalTl,
        ),
      ];
    } else {
      _totalAmountTl = 0;
      _installments = const [];
    }
    _totalController.text = formatThousands(_totalAmountTl);
    _countController.text = '${_installments.length}';
  }

  void _resplit({required int totalAmountTl, required int count}) {
    setState(() {
      _totalAmountTl = totalAmountTl;
      _installments = splitIntoInstallments(
        totalAmountTl: totalAmountTl,
        count: count,
        firstDueDate: DateTime.now(),
      );
    });
  }

  void _updateInstallment(
    int index, {
    required int amountTl,
    required DateTime dueDate,
    required bool paid,
  }) {
    setState(() {
      _installments = [
        for (final installment in _installments)
          if (installment.index == index)
            installment.copyWith(
              amountTl: amountTl,
              dueDate: dueDate,
              paid: paid,
            )
          else
            installment,
      ];
      _totalAmountTl = _installments.fold(0, (total, i) => total + i.amountTl);
      _totalController.text = formatThousands(_totalAmountTl);
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(adminMemberDetailControllerProvider(widget.memberId).notifier)
          .saveInstallmentPlan(
            totalAmountTl: _totalAmountTl,
            installments: _installments,
          );
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = 'Kaydedilemedi, bağlantını kontrol edip tekrar dene.';
        });
      }
      return;
    }
    if (mounted) ref.read(panelStackControllerProvider.notifier).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final detail = ref.watch(
      adminMemberDetailControllerProvider(widget.memberId),
    );
    _hydrate(detail);

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
                    'Ödeme bilgileri',
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
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    detail.name,
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 16,
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
                          label: 'Toplam tutar',
                          controller: _totalController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [ThousandsInputFormatter()],
                          onChanged: (value) {
                            final digits = value.replaceAll('.', '');
                            _resplit(
                              totalAmountTl: int.tryParse(digits) ?? 0,
                              count: _installments.isEmpty
                                  ? 1
                                  : _installments.length,
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Taksit sayısı',
                                style: typography.bodyLarge.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            _StepButton(
                              icon: Icons.remove,
                              onTap: () {
                                final next = _installments.length - 1;
                                if (next < 1) return;
                                _resplit(
                                  totalAmountTl: _totalAmountTl,
                                  count: next,
                                );
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
                                    _resplit(
                                      totalAmountTl: _totalAmountTl,
                                      count: parsed,
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
                                final next = _installments.length + 1;
                                if (next > 12) return;
                                _resplit(
                                  totalAmountTl: _totalAmountTl,
                                  count: next,
                                );
                                _countController.text = '$next';
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Divider(color: colors.outline, height: 1),
                        for (var i = 0; i < _installments.length; i++)
                          InstallmentRow(
                            installment: _installments[i],
                            showDivider: i < _installments.length - 1,
                            onTap: () => showInstallmentEditSheet(
                              context,
                              installment: _installments[i],
                              onSave:
                                  ({
                                    required amountTl,
                                    required dueDate,
                                    required paid,
                                  }) => _updateInstallment(
                                    _installments[i].index,
                                    amountTl: amountTl,
                                    dueDate: dueDate,
                                    paid: paid,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Üye kendi ekranında yalnızca taksitlerin ödenip ödenmediğini görür; tutarlar üyeye gösterilmez.',
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
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _isSaving ? 'Kaydediliyor…' : 'Kaydet',
                    onPressed: _isSaving ? null : _save,
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
