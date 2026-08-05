import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/admin_calendar_state.dart';
import '../repository/admin_calendar_repository.dart';

part 'admin_calendar_controller.g.dart';

/// Seçili ay/gün — [AdminCalendarController]'ın `state`'inden ayrı bir
/// provider'da tutuluyor çünkü Notifier'ın `build()` metodu kendi
/// `state`'ini henüz oluşturulmadan okuyamıyor.
@riverpod
class _SelectedCalendarDate extends _$SelectedCalendarDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

@riverpod
Stream<Map<int, List<AdminSessionSlot>>> _sessionsForGymMonth(
  _SessionsForGymMonthRef ref,
  String gymId,
  int year,
  int month,
) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 1);
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('gymId', isEqualTo: gymId)
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('startTime', isLessThan: Timestamp.fromDate(end))
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) {
        final byDay = <int, List<AdminSessionSlot>>{};
        for (final doc in snapshot.docs) {
          final slot = _toAdminSlot(doc);
          final day = (doc.data()['startTime'] as Timestamp).toDate().day;
          (byDay[day] ??= []).add(slot);
        }
        return byDay;
      });
}

AdminSessionSlot _toAdminSlot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final statusStr = data['status'] as String? ?? 'planned';
  final now = DateTime.now();
  final state = switch (statusStr) {
    'cancelled' => AdminSessionState.cancelled,
    'completed' => AdminSessionState.completed,
    _ => now.isAfter(startTime) && now.isBefore(startTime.add(const Duration(hours: 1)))
        ? AdminSessionState.current
        : AdminSessionState.planned,
  };
  return AdminSessionSlot(
    id: doc.id,
    time: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
    title: (data['memberName'] as String?) ?? '',
    meta: '${(data['trainerName'] as String?) ?? ''} · Birebir',
    state: state,
  );
}

/// F3-3 — aktif salonun bulunduğu aya ait seansları gerçek zamanlı
/// dinler. Salon bilinmiyorsa (test ortamı vb.) mock repository'e düşer.
@riverpod
class AdminCalendarController extends _$AdminCalendarController {
  @override
  AdminCalendarState build() {
    final selectedDate = ref.watch(_selectedCalendarDateProvider);
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      return ref.watch(adminCalendarRepositoryProvider).loadInitial().copyWith(selectedDate: selectedDate);
    }
    final slots = ref
        .watch(_sessionsForGymMonthProvider(gymId, selectedDate.year, selectedDate.month))
        .valueOrNull ??
        const {};
    return AdminCalendarState(selectedDate: selectedDate, slotsByDayOfMonth: slots);
  }

  void selectDate(DateTime date) => ref.read(_selectedCalendarDateProvider.notifier).select(date);
}
