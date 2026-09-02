import 'package:cloud_firestore/cloud_firestore.dart';

import 'trainer_member_detail.dart';
import '../../../shared/utils/date_labels.dart';
import 'trainer_metric.dart';

/// `TrainerMetric` <-> ölçüm modülünün `measurements/{uid}/entries`
/// dokümanlarındaki alan adı eşlemesi. `MeasurementMetric.kilo.name`/
/// `.yagOrani.name` ile birebir aynı olmalı (ölçüm ekranı bu alan
/// adlarıyla yazıyor, bkz. `measurements_write_service.dart`).
const _fieldByMetric = {
  TrainerMetric.kilo: 'kilo',
  TrainerMetric.belCevresi: 'bel',
  TrainerMetric.yagOrani: 'yagOrani',
};

/// Admin'in üye detayı ve antrenörün üye detayı ekranlarındaki metrik
/// dropdown'ı (kilo/bel çevresi/yağ oranı) için TEK bir Firestore
/// sorgusundan üç metriğin de serisini üretir — önceden sadece bel
/// çevresi doldurulup kilo/yağ oranı kalıcı olarak boş kalıyordu (ölçüm
/// ekranı o zaman bu ikisini hiç toplamıyordu).
Stream<Map<TrainerMetric, TrainerMetricSeries>> watchTrainerMetricSeries(
  String memberId,
  DateLabels labels,
) {
  return FirebaseFirestore.instance
      .collection('measurements')
      .doc(memberId)
      .collection('entries')
      .orderBy('date')
      .snapshots()
      .map((snapshot) {
        final result = <TrainerMetric, TrainerMetricSeries>{};
        for (final metric in TrainerMetric.values) {
          final field = _fieldByMetric[metric]!;
          final months = <String>[];
          final values = <double>[];
          for (final doc in snapshot.docs) {
            final data = doc.data();
            final raw = data[field];
            if (raw is num) {
              final date = (data['date'] as Timestamp).toDate();
              months.add(labels.monthShort(date.month));
              values.add(raw.toDouble());
            }
          }
          result[metric] = TrainerMetricSeries(
            metric: metric,
            values: values,
            months: months,
          );
        }
        return result;
      });
}
