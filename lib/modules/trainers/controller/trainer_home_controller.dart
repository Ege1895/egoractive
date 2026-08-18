import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../sessions/service/session_completion_service.dart';
import '../domain/pending_confirmation.dart';
import '../domain/schedule_slot.dart';
import '../domain/trainer_home_state.dart';
import '../repository/trainer_home_repository.dart';

part 'trainer_home_controller.g.dart';

@riverpod
Stream<List<ScheduleSlot>> _todayScheduleForTrainer(
  _TodayScheduleForTrainerRef ref,
  String trainerId,
) {
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
    _ =>
      now.isAfter(startTime) &&
              now.isBefore(startTime.add(const Duration(hours: 1)))
          ? ScheduleSlotState.current
          : ScheduleSlotState.planned,
  };
  return ScheduleSlot(
    id: doc.id,
    time:
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
    name: (data['memberName'] as String?) ?? '',
    meta: 'Birebir',
    state: state,
  );
}

/// F3-5 — antrenörün onayını bekleyen, bitiş saati geçmiş ama hâlâ
/// `planned` kalan seanslar. Her biri için üyenin güncel
/// `remainingSessions`'ı ayrıca okunur (onay ekranındaki "X'ten Y'ye
/// düşer" önizlemesi için) — pending sayısı genelde küçük olduğundan bu
/// ek okuma kabul edilebilir.
@riverpod
Stream<List<PendingConfirmation>> _pendingConfirmationsForTrainer(
  _PendingConfirmationsForTrainerRef ref,
  String trainerId,
) {
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('status', isEqualTo: 'planned')
      .orderBy('endTime')
      .snapshots()
      .asyncMap((snapshot) async {
        final now = DateTime.now();
        final items = <PendingConfirmation>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final endTime = (data['endTime'] as Timestamp?)?.toDate();
          if (endTime == null || endTime.isAfter(now)) continue;

          final memberId = data['memberId'] as String? ?? '';
          final memberName = (data['memberName'] as String?) ?? '';
          final startTime = (data['startTime'] as Timestamp).toDate();
          final memberDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(memberId)
              .get();
          final remaining =
              (memberDoc.data()?['remainingSessions'] as num?)?.toInt() ?? 0;

          items.add(
            PendingConfirmation(
              id: doc.id,
              memberId: memberId,
              memberInitials: _initialsFor(memberName),
              memberName: memberName,
              meta: 'Birebir · tamamlandı mı?',
              time:
                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
              remainingBefore: remaining,
            ),
          );
        }
        return items;
      });
}

String _initialsFor(String name) {
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}

/// F3-3/F3-5 — antrenörün "Bugünkü program"ı ve onay bekleyen seansları
/// gerçek zamanlı `sessions` koleksiyonundan (trainerId == kendi uid'si)
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

    // Oturum gerçekse (uid dolu) ama Firestore stream'i henüz ilk
    // snapshot'ını vermemişse — önceden bu pencerede mock'a düşülüyordu;
    // antrenör o an sahte bir "onay bekliyor" kartına (ör. 'pending-1',
    // 'mock-cem-demir') dokunursa gerçek olmayan bir sessionId/memberId
    // ile Firestore'a yazma denemesi hataya düşüyordu. Artık sadece
    // oturum yoksa mock, yükleniyorsa boş liste.
    final schedule =
        ref.watch(_todayScheduleForTrainerProvider(uid)).valueOrNull ??
        const <ScheduleSlot>[];
    final pending =
        ref.watch(_pendingConfirmationsForTrainerProvider(uid)).valueOrNull ??
        const [];

    final completedCount = schedule
        .where((s) => s.state == ScheduleSlotState.completed)
        .length;
    return mock.copyWith(
      todaySessionCount: schedule.length,
      completedCount: completedCount,
      freeSlotCount: 0,
      todaySchedule: schedule,
      pendingConfirmations: pending,
    );
  }

  Future<void> markCompleted(String pendingId) async {
    final matches = state.pendingConfirmations.where((p) => p.id == pendingId);
    if (matches.isEmpty) return;
    await ref
        .read(sessionCompletionServiceProvider)
        .markCompleted(sessionId: pendingId, memberId: matches.first.memberId);
  }

  Future<void> markAbsent(String pendingId) async {
    await ref.read(sessionCompletionServiceProvider).markAbsent(pendingId);
  }
}
