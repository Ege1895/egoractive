import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/measurement_metric.dart';

part 'measurements_write_service.g.dart';

/// F4-1 — `measurements/{uid}/entries/{entryId}` alt koleksiyonuna yazar.
class MeasurementsWriteService {
  const MeasurementsWriteService();

  Future<void> addEntry({
    required String uid,
    required DateTime date,
    required Map<MeasurementMetric, double> values,
  }) async {
    final data = <String, dynamic>{'date': Timestamp.fromDate(date)};
    for (final entry in values.entries) {
      data[entry.key.name] = entry.value;
    }
    await FirebaseFirestore.instance.collection('measurements').doc(uid).collection('entries').add(data);
  }
}

@riverpod
MeasurementsWriteService measurementsWriteService(MeasurementsWriteServiceRef ref) => const MeasurementsWriteService();
