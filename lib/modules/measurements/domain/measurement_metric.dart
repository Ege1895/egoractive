import '../../../core/remote_config/remote_config_service.dart';

enum MeasurementMetric { bel, gogus, kalca, kol, bacak, kilo, yagOrani }

extension MeasurementMetricLabel on MeasurementMetric {
  /// F7-x — görüntülenecek etiketin kendisi değil, RC anahtarı döner;
  /// çağıran taraf `ref.watch(rcTextProvider(metric.rcKey))` ile çözer
  /// (bkz. measurements_panel.dart/measurement_avatar.dart). Önceden bu
  /// getter doğrudan hardcoded Türkçe metin dönüyordu — app İngilizce iken
  /// de "Bel"/"Göğüs" gibi Türkçe kalıyordu.
  String get rcKey => switch (this) {
    MeasurementMetric.bel => RemoteConfigKeys.measurementsMetricBel,
    MeasurementMetric.gogus => RemoteConfigKeys.measurementsMetricGogus,
    MeasurementMetric.kalca => RemoteConfigKeys.measurementsMetricKalca,
    MeasurementMetric.kol => RemoteConfigKeys.measurementsMetricKol,
    MeasurementMetric.bacak => RemoteConfigKeys.measurementsMetricBacak,
    MeasurementMetric.kilo => RemoteConfigKeys.measurementsMetricKilo,
    MeasurementMetric.yagOrani => RemoteConfigKeys.measurementsMetricYagOrani,
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
