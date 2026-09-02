import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/currency_constants.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/money/active_gym_currency_provider.dart';
import '../../../../core/money/app_money_formatter.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_color_scheme.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/domain/membership_installment.dart';
import '../../../../shared/utils/date_labels.dart';

/// Tek bir taksit satırı (admin görünümü, tutar dahil) — admin taksit
/// oluştururken (`NewMembershipPaymentPanel`) ve mevcut bir üyenin
/// taksitlerini yönetirken (`AdminMemberDetailPanel`) aynı görünüm/dokunma
/// davranışı kullanılıyor.
class InstallmentRow extends ConsumerWidget {
  const InstallmentRow({
    required this.installment,
    this.onTap,
    this.showDivider = false,
    super.key,
  });

  final MembershipInstallment installment;

  /// `null` verilirse satır salt-okunur gösterilir (ör. dış bir dokunma
  /// alanının — tüm kartın — kendi navigasyonuyla çakışmasın diye).
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final row = _buildRow(ref, colors, typography);
    if (onTap == null) return row;

    return InkWell(onTap: onTap, child: row);
  }

  Widget _buildRow(
    WidgetRef ref,
    AppColorScheme colors,
    AppTypography typography,
  ) {
    final currency =
        ref.watch(activeGymCurrencyProvider).valueOrNull ?? defaultCurrencyCode;
    final locale = ref.watch(localeControllerProvider);
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
                  ref
                      .watch(
                        rcTextProvider(
                          RemoteConfigKeys
                              .sessionsMemberHomeInstallmentIndexLabel,
                        ),
                      )
                      .replaceAll('{index}', '${installment.index}'),
                  style: typography.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${formatMoney(installment.amountTl, currency, locale)} · ${ref.watch(dateLabelsProvider).dayMonthYear(installment.dueDate)}',
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
              installment.paid
                  ? ref.watch(
                      rcTextProvider(RemoteConfigKeys.membersDetailPaidLabel),
                    )
                  : ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys
                            .sessionsMemberHomeInstallmentUnpaidLabel,
                      ),
                    ),
              style: typography.caption.copyWith(
                color: installment.paid
                    ? colors.onSuccessContainer
                    : colors.onWarningContainer,
                fontSize: 12,
              ),
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ],
      ),
    );
  }
}
