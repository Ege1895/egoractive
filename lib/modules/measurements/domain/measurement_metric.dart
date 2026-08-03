enum MeasurementMetric { bel, gogus, kalca, kol, bacak }

extension MeasurementMetricLabel on MeasurementMetric {
  String get label => switch (this) {
        MeasurementMetric.bel => 'Bel',
        MeasurementMetric.gogus => 'Göğüs',
        MeasurementMetric.kalca => 'Kalça',
        MeasurementMetric.kol => 'Kol',
        MeasurementMetric.bacak => 'Bacak',
      };
}
