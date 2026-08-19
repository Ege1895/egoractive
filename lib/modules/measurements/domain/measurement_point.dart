import 'package:freezed_annotation/freezed_annotation.dart';

import 'measurement_metric.dart';

part 'measurement_point.freezed.dart';

enum AvatarSide { left, right }

/// Silüet üzerindeki tıklanabilir nokta konumları — gerçek ölçüm verisiyle
/// hiçbir ilgisi yok, sadece görsel bir yerleşim sabiti. `MeasurementAvatar`
/// bunun üzerinden TÜM metrikler için (henüz hiç ölçülmemiş olsalar bile)
/// bir dokunma hedefi çizer — [MeasurementsState.points] sadece gerçekten
/// kaydedilmiş metrikleri içerir.
const avatarLayout = {
  MeasurementMetric.gogus: (fx: 0.50, fy: 0.255, side: AvatarSide.right),
  MeasurementMetric.kol: (fx: 0.335, fy: 0.345, side: AvatarSide.left),
  MeasurementMetric.bel: (fx: 0.50, fy: 0.395, side: AvatarSide.right),
  MeasurementMetric.kalca: (fx: 0.50, fy: 0.475, side: AvatarSide.left),
  MeasurementMetric.bacak: (fx: 0.435, fy: 0.615, side: AvatarSide.right),
};

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
