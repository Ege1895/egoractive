import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_trainer_detail_stats.dart';

part 'admin_trainer_detail_controller.g.dart';

/// [AdminTrainerDetailPanel]'in tüm-zamanlı istatistikleri — antrenörün
/// `sessions` koleksiyonundaki her dokümanı okuyup durumuna göre sayar.
/// [reportForTrainerProvider] (bkz. `trainer_report_controller.dart`) bu ayla
/// sınırlı, bu provider ise "kaç ders yapmış toplam" sorusu için tüm zamanı
/// kapsar.
@riverpod
Stream<AdminTrainerDetailStats> adminTrainerDetailStats(
  AdminTrainerDetailStatsRef ref,
  String trainerId,
) async* {
  // `gymId` filtresi olmadan admin bağlamında `firestore.rules`'taki
  // `sessions` okuma kuralı bu sorguyu reddedebilir — bkz.
  // `trainer_report_controller.dart`'taki aynı düzeltmenin yorumu.
  final trainerDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(trainerId)
      .get();
  final gymId = trainerDoc.data()?['gymId'] as String?;

  var query = FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId);
  if (gymId != null) {
    query = query.where('gymId', isEqualTo: gymId);
  }

  yield* query.snapshots().map((snapshot) {
    var completed = 0;
    var cancelled = 0;
    var planned = 0;
    for (final doc in snapshot.docs) {
      switch (doc.data()['status'] as String? ?? 'planned') {
        case 'completed':
          completed++;
        case 'cancelled':
          cancelled++;
        default:
          planned++;
      }
    }
    return AdminTrainerDetailStats(
      totalSessions: snapshot.docs.length,
      completedSessions: completed,
      cancelledSessions: cancelled,
      plannedSessions: planned,
    );
  });
}
