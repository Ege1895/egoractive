import 'package:freezed_annotation/freezed_annotation.dart';

import 'measurement_metric.dart';

part 'measurement_point.freezed.dart';

enum AvatarSide { left, right }

/// Silüet üzerindeki tıklanabilir ölçüm noktalarından biri — imza öğesi
/// (nokta-küme motifi). fx/fy: silüet kutusuna göre oran (0-1).
@freezed
class MeasurementPoint with _$MeasurementPoint {
  const factory MeasurementPoint({
    required MeasurementMetric metric,
    required String value,
    required String delta,
    required bool isImprovement,
    required String since,
    required double fx,
    required double fy,
    required AvatarSide side,
  }) = _MeasurementPoint;
}
