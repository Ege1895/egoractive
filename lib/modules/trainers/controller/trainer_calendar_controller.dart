import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/schedule_slot.dart';
import '../domain/trainer_calendar_state.dart';
import '../repository/trainer_calendar_repository.dart';

part 'trainer_calendar_controller.g.dart';

/// Seçili ay/gün — `AdminCalendarController`'daki aynı desen: `build()`
/// kendi `state`'ini henüz oluşturulmadan okuyamadığı için ayrı bir
/// provider'da tutuluyor.
@riverpod
class _SelectedTrainerCalendarDate extends _$SelectedTrainerCalendarDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

@riverpod
Stream<Map<int, List<ScheduleSlot>>> _sessionsForTrainerMonth(
  _SessionsForTrainerMonthRef ref,
  String trainerId,
  int year,
  int month,
) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 1);
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('startTime', isLessThan: Timestamp.fromDate(end))
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) {
        final byDay = <int, List<ScheduleSlot>>{};
        for (final doc in snapshot.docs) {
          final slot = _toScheduleSlot(doc);
          final day = (doc.data()['startTime'] as Timestamp).toDate().day;
          (byDay[day] ??= []).add(slot);
        }
        return byDay;
      });
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

/// Antrenörün kendi (`trainerId == uid`) seansları gerçek zamanlı dinlenir.
/// Oturum yoksa (test ortamı vb.) mock repository'e düşer.
@riverpod
class TrainerCalendarController extends _$TrainerCalendarController {
  @override
  TrainerCalendarState build() {
    final selectedDate = ref.watch(_selectedTrainerCalendarDateProvider);
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      return ref
          .watch(trainerCalendarRepositoryProvider)
          .loadInitial()
          .copyWith(selectedDate: selectedDate);
    }
    final slots =
        ref
            .watch(
              _sessionsForTrainerMonthProvider(
                uid,
                selectedDate.year,
                selectedDate.month,
              ),
            )
            .valueOrNull ??
        const {};
    return TrainerCalendarState(
      selectedDate: selectedDate,
      slotsByDayOfMonth: slots,
    );
  }

  void setViewMode(TrainerCalendarViewMode mode) =>
      state = state.copyWith(viewMode: mode);

  void selectDate(DateTime date) =>
      ref.read(_selectedTrainerCalendarDateProvider.notifier).select(date);
}
