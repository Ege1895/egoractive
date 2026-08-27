import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';

/// Tek bir sayısal metriği (ör. toplam ders) gösteren kart — canlı dashboard
/// (F5-1) ve geçmiş rapor detayı (F5-9) arasında paylaşılır.
class ReportMetricCard extends StatelessWidget {
  const ReportMetricCard({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: typography.headingMedium.copyWith(
              color: color,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
