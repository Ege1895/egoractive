import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/schedule_slot.dart';
import '../domain/trainer_home_state.dart';
import '../repository/trainer_home_repository.dart';

part 'trainer_home_controller.g.dart';

@riverpod
Stream<List<ScheduleSlot>> _todayScheduleForTrainer(_TodayScheduleForTrainerRef ref, String trainerId) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  final end = start.add(const Duration(days: 1));
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('startTime', isLessThan: Timestamp.fromDate(end))
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_toScheduleSlot).toList());
}

ScheduleSlot _toScheduleSlot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final statusStr = data['status'] as String? ?? 'planned';
  final now = DateTime.now();
  final state = switch (statusStr) {
    'cancelled' => ScheduleSlotState.cancelled,
    'completed' => ScheduleSlotState.completed,
    _ => now.isAfter(startTime) && now.isBefore(startTime.add(const Duration(hours: 1)))
        ? ScheduleSlotState.current
        : ScheduleSlotState.planned,
  };
  return ScheduleSlot(
    id: doc.id,
    time: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
    name: (data['memberName'] as String?) ?? '',
    meta: 'Birebir',
    state: state,
  );
}

/// F3-3 — antrenörün "Bugünkü program"ı gerçek zamanlı `sessions`
/// koleksiyonundan (trainerId == kendi uid'si, bugünün tarih aralığı)
/// okunur. `freeSlotCount` boş bırakılıyor — stüdyo çalışma saatleri/
/// kapasite kavramı henüz tanımlı değil, bu yüzden 0 dönüyor (mock'taki
/// keyfi sayı yerine).
@riverpod
class TrainerHomeController extends _$TrainerHomeController {
  @override
  TrainerHomeState build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final mock = ref.watch(trainerHomeRepositoryProvider).loadInitial();
    if (uid == null) return mock;

    final schedule = ref.watch(_todayScheduleForTrainerProvider(uid)).valueOrNull;
    if (schedule == null) return mock;

    final completedCount = schedule.where((s) => s.state == ScheduleSlotState.completed).length;
    return mock.copyWith(
      todaySessionCount: schedule.length,
      completedCount: completedCount,
      freeSlotCount: 0,
      todaySchedule: schedule,
    );
  }

  void markCompleted(String pendingId) {
    state = state.copyWith(
      pendingConfirmations: state.pendingConfirmations.where((p) => p.id != pendingId).toList(),
      completedCount: state.completedCount + 1,
    );
  }

  void markAbsent(String pendingId) {
    state = state.copyWith(
      pendingConfirmations: state.pendingConfirmations.where((p) => p.id != pendingId).toList(),
    );
  }
}
