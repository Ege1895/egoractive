import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/money/app_money_formatter.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_report.dart';

/// Tahmini ciro / gider / net kâr-zarar özeti — canlı dashboard (F5-1) ve
/// geçmiş rapor detayı (F5-9) arasında paylaşılır. [currency] çağıran
/// tarafından verilir — canlı dashboard aktif salonun GÜNCEL para birimini,
/// geçmiş rapor detayı ise o snapshot'ın YAZILDIĞI andaki para birimini
/// kullanmalı (F9-4).
class ReportFinanceSummaryCard extends ConsumerWidget {
  const ReportFinanceSummaryCard({
    required this.report,
    required this.currency,
    super.key,
  });

  final DashboardReport report;
  final String currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final locale = ref.watch(localeControllerProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FinanceColumn(
              label: ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.gymsAdminHomeEstimatedRevenueLabel,
                ),
              ),
              value: formatMoney(report.estimatedRevenueTl, currency, locale),
              color: colors.onSurface,
            ),
          ),
          Expanded(
            child: _FinanceColumn(
              label: ref.watch(
                rcTextProvider(RemoteConfigKeys.gymsAdminHomeExpenseLabel),
              ),
              value: formatMoney(report.totalExpensesTl, currency, locale),
              color: colors.onSurface,
            ),
          ),
          Expanded(
            child: _FinanceColumn(
              label: ref.watch(
                rcTextProvider(RemoteConfigKeys.reportsNetLabel),
              ),
              value: formatMoney(report.netTl, currency, locale),
              color: report.netTl >= 0 ? colors.primary : colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceColumn extends StatelessWidget {
  const _FinanceColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.caption.copyWith(color: colors.onSurfaceMuted),
        ),
        Text(
          value,
          style: typography.headingMedium.copyWith(color: color, fontSize: 20),
        ),
      ],
    );
  }
}
