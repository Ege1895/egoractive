import 'package:freezed_annotation/freezed_annotation.dart';

import 'measurement_metric.dart';
import 'measurement_point.dart';
import 'measurement_series.dart';

part 'measurements_state.freezed.dart';

enum MeasurementsViewMode { avatar, chart }

@freezed
class MeasurementsState with _$MeasurementsState {
  const factory MeasurementsState({
    required Map<MeasurementMetric, MeasurementPoint> points,
    required Map<MeasurementMetric, MeasurementSeries> series,
    @Default(MeasurementsViewMode.avatar) MeasurementsViewMode viewMode,
    @Default(MeasurementMetric.bel) MeasurementMetric selectedMetric,
  }) = _MeasurementsState;
}
