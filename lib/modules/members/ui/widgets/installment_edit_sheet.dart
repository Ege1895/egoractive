import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/membership_installment.dart';
import '../../../../shared/utils/thousands_input_formatter.dart';
import '../../../../shared/utils/tr_date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/native_date_picker.dart';

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

class _InstallmentEditSheet extends StatefulWidget {
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
  State<_InstallmentEditSheet> createState() => _InstallmentEditSheetState();
}

class _InstallmentEditSheetState extends State<_InstallmentEditSheet> {
  late final TextEditingController _amountController;
  late DateTime _dueDate;
  late bool _paid;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: formatThousands(widget.installment.amountTl),
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
            '${widget.installment.index}. Taksit',
            style: typography.headingMedium.copyWith(
              color: colors.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Tutar',
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [ThousandsInputFormatter()],
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
                      'Son ödeme tarihi',
                      style: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    formatTrDate(_dueDate),
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
                    'Ödendi mi?',
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                ),
                Switch(
                  value: _paid,
                  onChanged: (value) => setState(() => _paid = value),
                  activeThumbColor: colors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Kaydet',
            onPressed: () {
              final digits = _amountController.text.replaceAll('.', '');
              widget.onSave(
                amountTl: int.tryParse(digits) ?? widget.installment.amountTl,
                dueDate: _dueDate,
                paid: _paid,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
