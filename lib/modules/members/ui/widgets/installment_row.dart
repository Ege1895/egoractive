import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/membership_installment.dart';
import '../../../../shared/utils/thousands_input_formatter.dart';
import '../../../../shared/utils/tr_date_formatter.dart';

/// Tek bir taksit satırı (admin görünümü, tutar dahil) — admin taksit
/// oluştururken (`NewMembershipPaymentPanel`) ve mevcut bir üyenin
/// taksitlerini yönetirken (`AdminMemberDetailPanel`) aynı görünüm/dokunma
/// davranışı kullanılıyor.
class InstallmentRow extends StatelessWidget {
  const InstallmentRow({
    required this.installment,
    required this.onTap,
    this.showDivider = false,
    super.key,
  });

  final MembershipInstallment installment;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      onTap: onTap,
      child: Container(
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
                    '${installment.index}. Taksit',
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '₺${formatThousands(installment.amountTl)} · ${formatTrDate(installment.dueDate)}',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: installment.paid
                    ? colors.successContainer
                    : colors.warningContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                installment.paid ? 'Ödendi' : 'Ödenmedi',
                style: typography.caption.copyWith(
                  color: installment.paid
                      ? colors.onSuccessContainer
                      : colors.onWarningContainer,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
