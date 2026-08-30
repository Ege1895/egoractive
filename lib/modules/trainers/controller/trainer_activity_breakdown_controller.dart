import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_activity_breakdown.dart';

part 'trainer_activity_breakdown_controller.g.dart';

/// [AdminTrainerDetailPanel]'in "BU AY"/"BU HAFTA" bölümleri — tek bir
/// Firestore sorgusuyla (ay penceresi, hafta zaten onun alt kümesi) hem
/// aylık hem haftalık kırılımı üretir. `trainer_report_controller.dart`'taki
/// paylaşılan dönem seçiciyi (`_TrainerReportPeriod`) KASITLI OLARAK
/// kullanmıyor — o state başka bir ekranda (antrenörün kendi raporu)
/// değiştirilebiliyor, bu ekran her zaman sabit "bu ay"/"bu hafta"
/// göstermeli.
@riverpod
Future<TrainerActivityBreakdown> trainerActivityBreakdown(
  TrainerActivityBreakdownRef ref,
  String trainerId,
) async {
  final trainerDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(trainerId)
      .get();
  final gymId = trainerDoc.data()?['gymId'] as String?;

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month - 1, now.day);
  final weekStart = now.subtract(const Duration(days: 7));
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  // `gymId` filtresi olmadan admin bağlamında bu sorgu `firestore.rules`
  // tarafından reddedilebilir — bkz. `trainer_report_controller.dart`.
  var query = FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where(
        'startTime',
        isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
      )
      .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
  if (gymId != null) {
    query = query.where('gymId', isEqualTo: gymId);
  }
  final snapshot = await query.get();

  TrainerActivityCounts countSince(DateTime rangeStart) {
    var individualCompleted = 0;
    var individualPlanned = 0;
    final duetCompletedGroups = <String>{};
    final duetPlannedGroups = <String>{};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final startTime = (data['startTime'] as Timestamp?)?.toDate();
      if (startTime == null || startTime.isBefore(rangeStart)) continue;

      final status = data['status'] as String? ?? 'planned';
      final isDuet = data['sessionType'] == 'duet';

      if (isDuet) {
        // Bir düet dersin her üyesi kendi dokümanına sahip (aynı
        // `duetGroupId`'yi paylaşıyor) — çift saymamak için grup id'ye
        // göre tekilleştiriliyor.
        final groupId = data['duetGroupId'] as String?;
        if (groupId == null) continue;
        if (status == 'completed') {
          duetCompletedGroups.add(groupId);
        } else if (status == 'planned') {
          duetPlannedGroups.add(groupId);
        }
      } else {
        if (status == 'completed') {
          individualCompleted++;
        } else if (status == 'planned') {
          individualPlanned++;
        }
      }
    }

    return TrainerActivityCounts(
      individualCompleted: individualCompleted,
      individualPlanned: individualPlanned,
      duetCompleted: duetCompletedGroups.length,
      duetPlanned: duetPlannedGroups.length,
    );
  }

  return TrainerActivityBreakdown(
    monthly: countSince(monthStart),
    weekly: countSince(weekStart),
  );
}
