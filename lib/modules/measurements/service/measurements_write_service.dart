import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/measurement_metric.dart';

part 'measurements_write_service.g.dart';

/// F4-1 — `measurements/{uid}/entries/{entryId}` alt koleksiyonuna yazar.
///
/// Doküman ID'si cihazın yerel takvim gününe (`yyyy-MM-dd`) sabitlenir.
/// Avatar ekranından tek tek metrik girildiği için (bkz. `MeasurementsPanel`
/// — her dokunma tek bir metriği kaydeder) `merge: true` kullanılıyor:
/// aynı gün içinde önce "bel", sonra "kol" kaydedilirse ikinci yazım
/// birinciyi silmez, aynı günün dokümanına eklenir.
class MeasurementsWriteService {
  const MeasurementsWriteService();

  Future<void> addEntry({
    required String uid,
    required DateTime date,
    required Map<MeasurementMetric, double> values,
  }) async {
    final dayKey = _dayKey(date);
    final data = <String, dynamic>{
      'date': Timestamp.fromDate(DateTime(date.year, date.month, date.day)),
    };
    for (final entry in values.entries) {
      data[entry.key.name] = entry.value;
    }
    await FirebaseFirestore.instance
        .collection('measurements')
        .doc(uid)
        .collection('entries')
        .doc(dayKey)
        .set(data, SetOptions(merge: true));
  }

  String _dayKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

@riverpod
MeasurementsWriteService measurementsWriteService(
  MeasurementsWriteServiceRef ref,
) => const MeasurementsWriteService();
