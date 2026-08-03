import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/measurement_metric.dart';
import '../domain/measurement_point.dart';
import '../domain/measurement_series.dart';
import '../domain/measurements_state.dart';

part 'measurements_service.g.dart';

/// Mock servis — Faz 4'te `measurements/{uid}/entries` alt koleksiyonuna
/// bağlanacak.
class MeasurementsService {
  const MeasurementsService();

  MeasurementsState loadInitial() {
    return MeasurementsState(
      points: const {
        MeasurementMetric.gogus: MeasurementPoint(
          metric: MeasurementMetric.gogus,
          value: '88,0',
          delta: '−1,5 cm',
          isImprovement: true,
          since: 'Son ölçüm 12 Temmuz',
          fx: 0.50,
          fy: 0.255,
          side: AvatarSide.right,
        ),
        MeasurementMetric.kol: MeasurementPoint(
          metric: MeasurementMetric.kol,
          value: '28,5',
          delta: '+0,5 cm',
          isImprovement: true,
          since: 'Son ölçüm 12 Temmuz',
          fx: 0.335,
          fy: 0.345,
          side: AvatarSide.left,
        ),
        MeasurementMetric.bel: MeasurementPoint(
          metric: MeasurementMetric.bel,
          value: '74,5',
          delta: '−2,0 cm',
          isImprovement: true,
          since: 'Son ölçüm 12 Temmuz',
          fx: 0.50,
          fy: 0.395,
          side: AvatarSide.right,
        ),
        MeasurementMetric.kalca: MeasurementPoint(
          metric: MeasurementMetric.kalca,
          value: '96,0',
          delta: '−1,0 cm',
          isImprovement: true,
          since: 'Son ölçüm 12 Temmuz',
          fx: 0.50,
          fy: 0.475,
          side: AvatarSide.left,
        ),
        MeasurementMetric.bacak: MeasurementPoint(
          metric: MeasurementMetric.bacak,
          value: '55,0',
          delta: '+1,0 cm',
          isImprovement: false,
          since: 'Son ölçüm 12 Temmuz',
          fx: 0.435,
          fy: 0.615,
          side: AvatarSide.right,
        ),
      },
      series: {
        MeasurementMetric.bel: const MeasurementSeries(
          metric: MeasurementMetric.bel,
          months: ['Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem'],
          values: [79.5, 78.5, 77.0, 76.5, 76.5, 74.5],
          totalDeltaLabel: '−5,0 cm',
        ),
        MeasurementMetric.gogus: const MeasurementSeries(
          metric: MeasurementMetric.gogus,
          months: ['Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem'],
          values: [90.0, 89.5, 89.5, 89.0, 89.5, 88.0],
          totalDeltaLabel: '−2,0 cm',
        ),
        MeasurementMetric.kalca: const MeasurementSeries(
          metric: MeasurementMetric.kalca,
          months: ['Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem'],
          values: [99.0, 98.5, 98.0, 97.0, 97.0, 96.0],
          totalDeltaLabel: '−3,0 cm',
        ),
        MeasurementMetric.kol: const MeasurementSeries(
          metric: MeasurementMetric.kol,
          months: ['Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem'],
          values: [26.5, 27.0, 27.5, 27.5, 28.0, 28.5],
          totalDeltaLabel: '+2,0 cm',
        ),
        MeasurementMetric.bacak: const MeasurementSeries(
          metric: MeasurementMetric.bacak,
          months: ['Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem'],
          values: [52.0, 52.5, 53.5, 54.0, 54.0, 55.0],
          totalDeltaLabel: '+3,0 cm',
        ),
      },
    );
  }
}

@riverpod
MeasurementsService measurementsService(MeasurementsServiceRef ref) => const MeasurementsService();
