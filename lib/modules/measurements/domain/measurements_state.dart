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

    /// Avatar ekranında görüntülenen kayıt tarihi. `null` = en son kayıt.
    DateTime? selectedDate,

    /// Geçmişe dönük tarih seçmek için — en yeniden en eskiye sıralı,
    /// gerçek veri yoksa boş.
    @Default(<DateTime>[]) List<DateTime> recordedDates,

    /// `points`/`series` gerçek bir kayda mı dayanıyor, yoksa (henüz hiç
    /// ölçümü olmayan bir üye için) örnek/mock veriye mi düşüldü —
    /// [AddMeasurementPanel] formu sadece gerçek veriyle önceden
    /// doldurmalı, mock değerleri gerçek ölçüm gibi göstermemeli.
    @Default(false) bool hasRealData,
  }) = _MeasurementsState;
}
