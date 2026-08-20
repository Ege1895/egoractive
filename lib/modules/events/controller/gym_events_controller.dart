import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/gym_event.dart';
import '../repository/gym_events_repository.dart';

part 'gym_events_controller.g.dart';

const _monthAbbrev = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

@riverpod
Stream<List<GymEvent>> _eventsForGym(_EventsForGymRef ref, String gymId) {
  final now = Timestamp.now();
  return FirebaseFirestore.instance
      .collection('events')
      .where('gymId', isEqualTo: gymId)
      .where('dateTime', isGreaterThanOrEqualTo: now)
      .orderBy('dateTime')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_toGymEvent).toList());
}

GymEvent _toGymEvent(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final dateTime = (data['dateTime'] as Timestamp).toDate();
  final time =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  final attendeeIds = List<String>.from(
    data['attendeeIds'] as List? ?? const [],
  );
  return GymEvent(
    id: doc.id,
    name: (data['name'] as String?) ?? '',
    location: (data['location'] as String?) ?? '',
    day: dateTime.day.toString().padLeft(2, '0'),
    month: _monthAbbrev[dateTime.month] ?? '',
    meta: '${(data['location'] as String?) ?? ''} · $time',
    joined: attendeeIds.length,
    capacity: (data['capacity'] as num?)?.toInt(),
  );
}

/// F4-3 — salonun ileri tarihli, gerçek zamanlı etkinlikleri.
@riverpod
class GymEventsController extends _$GymEventsController {
  @override
  List<GymEvent> build() {
    final gymIdAsync = ref.watch(activeGymIdProvider);
    // activeGymIdProvider ilk izlendiğinde henüz sonuçlanmamış olabilir —
    // bu durum "gerçekten salon yok" ile aynı değil; o ana kadar mock'a
    // düşülürse admin panelinde bir an sahte etkinlik/katılımcı sayısı
    // gerçekmiş gibi görünür.
    if (gymIdAsync.isLoading) return const [];
    final gymId = gymIdAsync.valueOrNull;
    if (gymId == null) {
      return ref.watch(gymEventsRepositoryProvider).loadEvents();
    }
    return ref.watch(_eventsForGymProvider(gymId)).valueOrNull ?? const [];
  }
}
