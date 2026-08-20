import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/remote_config/remote_config_service.dart';
import '../../core/theme/app_theme.dart';

/// P2-5 (Ölçümlerim) grafik kartından çıkarılan, antrenör üye detayında da
/// kullanılan genel amaçlı dikey çubuk grafik — her çubuğun üstünde değer,
/// altında etiket gösterir, son çubuk vurgulanır.
class TrendBarChart extends StatelessWidget {
  const TrendBarChart({
    required this.values,
    required this.labels,
    required this.valueFormatter,
    this.height = 160,
    super.key,
  });

  final List<double> values;
  final List<String> labels;
  final String Function(double value) valueFormatter;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    if (values.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Consumer(
            builder: (context, ref, _) => Text(
              ref.watch(rcTextProvider(RemoteConfigKeys.commonHenuzVeriYok)),
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
              ),
            ),
          ),
        ),
      );
    }
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      valueFormatter(values[i]),
                      textAlign: TextAlign.center,
                      style: typography.dataSmall.copyWith(
                        fontSize: 12,
                        color: i == values.length - 1
                            ? colors.onPrimaryContainer
                            : colors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor:
                            0.22 + ((values[i] - minVal) / range) * 0.68,
                        child: Container(
                          decoration: BoxDecoration(
                            color: i == values.length - 1
                                ? colors.primary
                                : colors.primary.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
