import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/measurement_metric.dart';
import '../domain/measurements_state.dart';
import '../repository/measurements_repository.dart';

part 'measurements_controller.g.dart';

@riverpod
class MeasurementsController extends _$MeasurementsController {
  @override
  MeasurementsState build() => ref.watch(measurementsRepositoryProvider).loadInitial();

  void selectPoint(MeasurementMetric metric) {
    state = state.copyWith(selectedMetric: metric);
  }

  void setViewMode(MeasurementsViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  /// Yeni ölçüm ekle formundan gelen değerleri ilgili metriklere işler —
  /// boş bırakılan alanlar atlanır (grafikte kırılma olmaz).
  void addMeasurement(Map<MeasurementMetric, double> newValues) {
    final updatedSeries = {...state.series};
    final updatedPoints = {...state.points};

    for (final entry in newValues.entries) {
      final series = updatedSeries[entry.key];
      if (series == null) continue;
      final previous = series.values.isNotEmpty ? series.values.last : entry.value;
      final nextValues = [...series.values, entry.value];
      updatedSeries[entry.key] = series.copyWith(values: nextValues);

      final diff = entry.value - previous;
      final formattedDiff = diff.abs().toStringAsFixed(1).replaceAll('.', ',');
      final point = updatedPoints[entry.key];
      if (point != null) {
        updatedPoints[entry.key] = point.copyWith(
          value: entry.value.toStringAsFixed(1).replaceAll('.', ','),
          delta: diff == 0 ? 'değişim yok' : '${diff < 0 ? '−' : '+'}$formattedDiff cm',
          isImprovement: diff <= 0,
          since: 'Az önce eklendi',
        );
      }
    }

    state = state.copyWith(series: updatedSeries, points: updatedPoints);
  }
}
