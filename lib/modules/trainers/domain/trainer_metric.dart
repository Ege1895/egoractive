enum TrainerMetric { kilo, belCevresi, yagOrani }

extension TrainerMetricLabel on TrainerMetric {
  String get label => switch (this) {
        TrainerMetric.kilo => 'Kilo',
        TrainerMetric.belCevresi => 'Bel çevresi',
        TrainerMetric.yagOrani => 'Yağ oranı',
      };

  String get unit => switch (this) {
        TrainerMetric.kilo => 'kg',
        TrainerMetric.belCevresi => 'cm',
        TrainerMetric.yagOrani => '%',
      };
}
