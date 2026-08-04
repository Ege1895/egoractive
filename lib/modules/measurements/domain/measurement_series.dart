import 'package:freezed_annotation/freezed_annotation.dart';

import 'measurement_metric.dart';

part 'measurement_series.freezed.dart';

@freezed
class MeasurementSeries with _$MeasurementSeries {
  const factory MeasurementSeries({
    required MeasurementMetric metric,
    required List<String> months,
    required List<double> values,
    required String totalDeltaLabel,
  }) = _MeasurementSeries;
}

@freezed
class MeasurementHistoryEntry with _$MeasurementHistoryEntry {
  const factory MeasurementHistoryEntry({
    required String date,
    required double value,
    required String? deltaLabel,
    required bool? isImprovement,
  }) = _MeasurementHistoryEntry;
}
