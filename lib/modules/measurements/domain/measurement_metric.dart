enum MeasurementMetric { bel, gogus, kalca, kol, bacak, kilo, yagOrani }

extension MeasurementMetricLabel on MeasurementMetric {
  String get label => switch (this) {
    MeasurementMetric.bel => 'Bel',
    MeasurementMetric.gogus => 'Göğüs',
    MeasurementMetric.kalca => 'Kalça',
    MeasurementMetric.kol => 'Kol',
    MeasurementMetric.bacak => 'Bacak',
    MeasurementMetric.kilo => 'Kilo',
    MeasurementMetric.yagOrani => 'Yağ oranı',
  };

  /// Çevre ölçüleri (bel/göğüs/kalça/kol/bacak) cm, kilo kg, yağ oranı %
  /// cinsinden — birim sembolleri dile göre değişmediği için (CLAUDE.md
  /// §2.5'teki "teknik sabit" istisnası) sabit tutuluyor, RC'ye taşınmıyor.
  String get unit => switch (this) {
    MeasurementMetric.kilo => 'kg',
    MeasurementMetric.yagOrani => '%',
    MeasurementMetric.bel ||
    MeasurementMetric.gogus ||
    MeasurementMetric.kalca ||
    MeasurementMetric.kol ||
    MeasurementMetric.bacak => 'cm',
  };
}
