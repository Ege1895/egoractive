import '../../../core/remote_config/remote_config_service.dart';

enum TrainerMetric { kilo, belCevresi, yagOrani }

extension TrainerMetricLabel on TrainerMetric {
  /// F7-x — önceden hardcoded Türkçe metin dönüyordu, app İngilizce iken de
  /// Türkçe kalıyordu. Artık RC anahtarı döner, çağıran taraf
  /// `ref.watch(rcTextProvider(metric.rcKey))` ile çözer.
  String get rcKey => switch (this) {
    TrainerMetric.kilo => RemoteConfigKeys.measurementsMetricKilo,
    TrainerMetric.belCevresi => RemoteConfigKeys.trainersMetricBelCevresi,
    TrainerMetric.yagOrani => RemoteConfigKeys.measurementsMetricYagOrani,
  };

  String get unit => switch (this) {
    TrainerMetric.kilo => 'kg',
    TrainerMetric.belCevresi => 'cm',
    TrainerMetric.yagOrani => '%',
  };
}
