import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../../expenses/domain/expense_state.dart';
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
        // Bir düet dersin her üyesi kendi dokümanına sahip (aynı
        // `duetGroupId`'yi paylaşırlar) — takvimde her üye için ayrı bir
        // satır göstermemek için önce düet dokümanları grup id'ye göre
        // toplanıp TEK bir slota indirgeniyor (bkz. `_toDuetAdminSlot`).
        final duetGroups =
            <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};
        final individualDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final duetGroupId = data['duetGroupId'] as String?;
          if (data['sessionType'] == 'duet' && duetGroupId != null) {
            (duetGroups[duetGroupId] ??= []).add(doc);
          } else {
            individualDocs.add(doc);
          }
        }

        final byDay = <int, List<AdminSessionSlot>>{};
        for (final doc in individualDocs) {
          final slot = _toAdminSlot(doc);
          final day = (doc.data()['startTime'] as Timestamp).toDate().day;
          (byDay[day] ??= []).add(slot);
        }
        for (final groupDocs in duetGroups.values) {
          final slot = _toDuetAdminSlot(groupDocs);
          final day = (groupDocs.first.data()['startTime'] as Timestamp)
              .toDate()
              .day;
          (byDay[day] ??= []).add(slot);
        }
        for (final slots in byDay.values) {
          slots.sort((a, b) => a.time.compareTo(b.time));
        }
        return byDay;
      });
}

@riverpod
Stream<Map<int, List<ExpenseEntry>>> _expensesForGymMonth(
  _ExpensesForGymMonthRef ref,
  String gymId,
  int year,
  int month,
) {
  final start = DateTime(year, month, 1);
  final end = DateTime(year, month + 1, 1);
  return FirebaseFirestore.instance
      .collection('expenses')
      .where('gymId', isEqualTo: gymId)
      .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('date', isLessThan: Timestamp.fromDate(end))
      .snapshots()
      .map((snapshot) {
        final byDay = <int, List<ExpenseEntry>>{};
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final day = (data['date'] as Timestamp).toDate().day;
          (byDay[day] ??= []).add(
            ExpenseEntry(
              id: doc.id,
              category: (data['category'] as String?) ?? '',
              title: (data['title'] as String?) ?? '',
              date: '',
              amountTl: (data['amountTl'] as num?)?.toInt() ?? 0,
              recurring: (data['recurring'] as bool?) ?? false,
            ),
          );
        }
        return byDay;
      });
}

AdminSessionState _slotStateFrom(
  String statusStr,
  DateTime startTime,
  bool? attended,
) {
  final now = DateTime.now();
  return switch (statusStr) {
    'cancelled' => AdminSessionState.cancelled,
    'completed' =>
      attended == false
          ? AdminSessionState.absent
          : AdminSessionState.completed,
    _ =>
      now.isAfter(startTime) &&
              now.isBefore(startTime.add(const Duration(hours: 1)))
          ? AdminSessionState.current
          : AdminSessionState.planned,
  };
}

String _formatSlotTime(DateTime startTime) =>
    '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';

AdminSessionSlot _toAdminSlot(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final statusStr = data['status'] as String? ?? 'planned';
  final attended = data['attended'] as bool?;
  return AdminSessionSlot(
    id: doc.id,
    time: _formatSlotTime(startTime),
    title: (data['memberName'] as String?) ?? '',
    // Tür etiketi ("Birebir"/"Düet") burada değil, UI katmanında RC'den
    // ekleniyor (bkz. admin_calendar_panel.dart) — bu katman metin
    // içermemeli.
    meta: (data['trainerName'] as String?) ?? '',
    state: _slotStateFrom(statusStr, startTime, attended),
    memberId: (data['memberId'] as String?) ?? '',
    sessionIds: [doc.id],
  );
}

/// F7-x — bir düet dersin tüm üye dokümanlarını (aynı `duetGroupId`) TEK
/// bir slota indirger. Zaman/durum/antrenör bilgisi tüm üyelerde aynı
/// olduğundan ilk dokümandan okunur; üye adları [AdminSessionSlot.title]'da
/// virgülle birleştirilir, ayrıca [AdminSessionSlot.duetMemberNames]'te
/// ayrı ayrı da tutulur (detay popup'ında liste olarak göstermek için).
AdminSessionSlot _toDuetAdminSlot(
  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
) {
  final first = docs.first.data();
  final startTime = (first['startTime'] as Timestamp).toDate();
  final statusStr = first['status'] as String? ?? 'planned';
  final attended = first['attended'] as bool?;
  final memberNames = docs
      .map((doc) => (doc.data()['memberName'] as String?) ?? '')
      .where((name) => name.isNotEmpty)
      .toList();
  return AdminSessionSlot(
    id: docs.first.id,
    time: _formatSlotTime(startTime),
    title: memberNames.join(', '),
    meta: (first['trainerName'] as String?) ?? '',
    state: _slotStateFrom(statusStr, startTime, attended),
    memberId: (first['memberId'] as String?) ?? '',
    sessionType: 'duet',
    duetMemberNames: memberNames,
    sessionIds: docs.map((doc) => doc.id).toList(),
  );
}

/// F3-3 — aktif salonun bulunduğu aya ait seansları gerçek zamanlı
/// dinler. Salon bilinmiyorsa (test ortamı vb.) mock repository'e düşer.
@riverpod
class AdminCalendarController extends _$AdminCalendarController {
  @override
  AdminCalendarState build() {
    final selectedDate = ref.watch(_selectedCalendarDateProvider);
    final gymIdAsync = ref.watch(activeGymIdProvider);
    // activeGymIdProvider kendi custom-claim okumasını yapıyor; bu panel
    // ilk açıldığında henüz sonuçlanmamış olabilir — bu "gerçekten salon
    // yok" ile aynı şey değil. O ana kadar mock'a düşülürse admin sahte bir
    // seans kartına dokunup geçersiz id ile Firestore'a yazma denemesi
    // yapabilir; bunun yerine boş takvim gösterilir.
    if (gymIdAsync.isLoading) {
      return AdminCalendarState(
        selectedDate: selectedDate,
        slotsByDayOfMonth: const {},
      );
    }
    final gymId = gymIdAsync.valueOrNull;
    if (gymId == null) {
      return ref
          .watch(adminCalendarRepositoryProvider)
          .loadInitial()
          .copyWith(selectedDate: selectedDate);
    }
    final slots =
        ref
            .watch(
              _sessionsForGymMonthProvider(
                gymId,
                selectedDate.year,
                selectedDate.month,
              ),
            )
            .valueOrNull ??
        const {};
    final expenses =
        ref
            .watch(
              _expensesForGymMonthProvider(
                gymId,
                selectedDate.year,
                selectedDate.month,
              ),
            )
            .valueOrNull ??
        const {};
    return AdminCalendarState(
      selectedDate: selectedDate,
      slotsByDayOfMonth: slots,
      expensesByDayOfMonth: expenses,
    );
  }

  void selectDate(DateTime date) =>
      ref.read(_selectedCalendarDateProvider.notifier).select(date);
}
