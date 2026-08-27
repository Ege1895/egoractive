import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/dashboard_report.dart';

/// Antrenör bazlı tamamlanan ders sayısı bar chart'ı — [trainerPerformance]
/// boşsa RC'den okunan boş durum metnini gösterir. Canlı dashboard (F5-1)
/// ve geçmiş rapor detayı (F5-9) arasında paylaşılır.
class ReportTrainerPerformanceChart extends ConsumerWidget {
  const ReportTrainerPerformanceChart({
    required this.trainerPerformance,
    super.key,
  });

  final List<TrainerPerformance> trainerPerformance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    if (trainerPerformance.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          ref.watch(
            rcTextProvider(
              RemoteConfigKeys.reportsTrainerPerformanceEmptyState,
            ),
          ),
          style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
        ),
      );
    }

    final maxCompleted = trainerPerformance
        .map((t) => t.completedSessions)
        .fold(0, (a, b) => a > b ? a : b);
    final chartMax = (maxCompleted == 0 ? 1 : maxCompleted).toDouble() * 1.25;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: chartMax,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= trainerPerformance.length) {
                    return const SizedBox.shrink();
                  }
                  final name = trainerPerformance[index].name;
                  final shortName = name.split(' ').first;
                  return Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      shortName,
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < trainerPerformance.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: trainerPerformance[i].completedSessions.toDouble(),
                    color: colors.primary,
                    width: 22,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
