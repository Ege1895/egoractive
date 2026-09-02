import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/money/app_money_formatter.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/membership_installment.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../../../shared/utils/date_labels.dart';

/// Bir taksitin tutarını/son ödeme tarihini/ödendi durumunu düzenleme
/// popup'ı — hem paket oluşturma (yerel state) hem de mevcut bir üyenin
/// taksitini güncelleme (Firestore yazımı) aynı sheet'i kullanır, [onSave]
/// ile davranış ayrılır.
Future<void> showInstallmentEditSheet(
  BuildContext context, {
  required MembershipInstallment installment,
  required void Function({
    required int amountTl,
    required DateTime dueDate,
    required bool paid,
  })
  onSave,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) =>
        _InstallmentEditSheet(installment: installment, onSave: onSave),
  );
}

class _InstallmentEditSheet extends ConsumerStatefulWidget {
  const _InstallmentEditSheet({
    required this.installment,
    required this.onSave,
  });

  final MembershipInstallment installment;
  final void Function({
    required int amountTl,
    required DateTime dueDate,
    required bool paid,
  })
  onSave;

  @override
  ConsumerState<_InstallmentEditSheet> createState() =>
      _InstallmentEditSheetState();
}

class _InstallmentEditSheetState extends ConsumerState<_InstallmentEditSheet> {
  late final TextEditingController _amountController;
  late DateTime _dueDate;
  late bool _paid;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: formatAmountGrouped(
        widget.installment.amountTl,
        ref.read(localeControllerProvider),
      ),
    );
    _dueDate = widget.installment.dueDate;
    _paid = widget.installment.paid;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref
                .watch(
                  rcTextProvider(
                    RemoteConfigKeys.sessionsMemberHomeInstallmentIndexLabel,
                  ),
                )
                .replaceAll('{index}', '${widget.installment.index}'),
            style: typography.headingMedium.copyWith(
              color: colors.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: ref.watch(
              rcTextProvider(
                RemoteConfigKeys.membersInstallmentAmountFieldLabel,
              ),
            ),
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              AppMoneyInputFormatter(
                locale: ref.watch(localeControllerProvider),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            onTap: () => showNativeDatePicker(
              context: context,
              initial: _dueDate,
              firstDate: DateTime(_dueDate.year - 2),
              lastDate: DateTime(_dueDate.year + 5),
              onSelected: (date) => setState(() => _dueDate = date),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              constraints: const BoxConstraints(minHeight: 52),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.membersPaymentDueDateFieldLabel,
                        ),
                      ),
                      style: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    ref.watch(dateLabelsProvider).dayMonthYear(_dueDate),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 15,
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
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            constraints: const BoxConstraints(minHeight: 52),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.membersInstallmentPaidToggleLabel,
                      ),
                    ),
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _paid = !_paid),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 52,
                    height: 32,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: _paid ? colors.primary : colors.outlineStrong,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    alignment: _paid
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: colors.onSurface,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: ref.watch(rcTextProvider(RemoteConfigKeys.commonKaydet)),
            onPressed: () {
              final amount = _amountController.text.isEmpty
                  ? widget.installment.amountTl
                  : parseMoneyInput(
                      _amountController.text,
                      ref.read(localeControllerProvider),
                    );
              widget.onSave(amountTl: amount, dueDate: _dueDate, paid: _paid);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
