import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../../events/service/events_write_service.dart';
import '../domain/discover_item.dart';
import '../repository/discover_repository.dart';
import '../service/group_sessions_write_service.dart';

part 'discover_controller.g.dart';

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
const _weekdayNames = {
  1: 'Pazartesi',
  2: 'Salı',
  3: 'Çarşamba',
  4: 'Perşembe',
  5: 'Cuma',
  6: 'Cumartesi',
  7: 'Pazar',
};

@riverpod
Stream<List<DiscoverItem>> _groupSessionsForGym(
  _GroupSessionsForGymRef ref,
  String gymId,
  String myUid,
) {
  final lockHours = ref
      .watch(remoteConfigServiceProvider)
      .groupSessionLockHoursBefore;
  final now = Timestamp.now();
  return FirebaseFirestore.instance
      .collection('groupSessions')
      .where('gymId', isEqualTo: gymId)
      .where('startTime', isGreaterThanOrEqualTo: now)
      .orderBy('startTime')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => _toGroupSessionItem(doc, myUid, lockHours))
            .toList(),
      );
}

DiscoverItem _toGroupSessionItem(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
  String myUid,
  int lockHours,
) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final attendeeIds = List<String>.from(
    data['attendeeIds'] as List? ?? const [],
  );
  final durationMinutes = (data['durationMinutes'] as num?)?.toInt() ?? 0;
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  return DiscoverItem(
    id: doc.id,
    category: DiscoverCategory.groupSessions,
    day: startTime.day.toString().padLeft(2, '0'),
    month: _monthAbbrev[startTime.month] ?? '',
    title: (data['title'] as String?) ?? '',
    meta:
        '${(data['trainerName'] as String?) ?? ''} · ${_weekdayNames[startTime.weekday]} $time · $durationMinutes dk',
    taken: attendeeIds.length,
    capacity: (data['capacity'] as num?)?.toInt(),
    joined: attendeeIds.contains(myUid),
    startTime: startTime,
    lockHoursBefore: lockHours,
  );
}

@riverpod
Stream<List<DiscoverItem>> _eventsForGym(
  _EventsForGymRef ref,
  String gymId,
  String myUid,
) {
  final lockHours = ref
      .watch(remoteConfigServiceProvider)
      .groupSessionLockHoursBefore;
  final now = Timestamp.now();
  return FirebaseFirestore.instance
      .collection('events')
      .where('gymId', isEqualTo: gymId)
      .where('dateTime', isGreaterThanOrEqualTo: now)
      .orderBy('dateTime')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => _toEventItem(doc, myUid, lockHours))
            .toList(),
      );
}

DiscoverItem _toEventItem(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
  String myUid,
  int lockHours,
) {
  final data = doc.data();
  final dateTime = (data['dateTime'] as Timestamp).toDate();
  final attendeeIds = List<String>.from(
    data['attendeeIds'] as List? ?? const [],
  );
  final time =
      '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  return DiscoverItem(
    id: doc.id,
    category: DiscoverCategory.events,
    day: dateTime.day.toString().padLeft(2, '0'),
    month: _monthAbbrev[dateTime.month] ?? '',
    title: (data['name'] as String?) ?? '',
    meta:
        '${(data['location'] as String?) ?? ''} · ${_weekdayNames[dateTime.weekday]} $time',
    taken: attendeeIds.length,
    capacity: (data['capacity'] as num?)?.toInt(),
    joined: attendeeIds.contains(myUid),
    startTime: dateTime,
    lockHoursBefore: lockHours,
  );
}

/// F4-2/F4-3 — üyenin salonunda ileri tarihli, gerçek zamanlı grup dersleri
/// ve etkinlikler. Kontenjan katılım/ayrılma her iki kategori için de
/// `CapacityService` üzerinden ortak mantıkla yapılır.
@riverpod
class DiscoverController extends _$DiscoverController {
  @override
  List<DiscoverItem> build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final mock = ref.watch(discoverRepositoryProvider).loadItems();
    if (gymId == null || uid == null) return mock;

    // Oturum gerçekse (gymId/uid dolu) ama Firestore stream'i henüz ilk
    // snapshot'ını vermemişse — önceden bu pencerede mock'a düşülüyordu,
    // kullanıcı o an sahte bir öğeye (ör. mock event id'si) dokunursa
    // gerçek olmayan bir ID ile Firestore'a yazma denemesi hataya
    // düşüyordu. Artık sadece oturum yoksa mock, yükleniyorsa boş liste.
    final groupSessions =
        ref.watch(_groupSessionsForGymProvider(gymId, uid)).valueOrNull ??
        const [];
    final events =
        ref.watch(_eventsForGymProvider(gymId, uid)).valueOrNull ?? const [];

    return [...groupSessions, ...events];
  }

  Future<void> toggleJoin(String id) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    final matches = state.where((i) => i.id == id);
    if (uid == null || matches.isEmpty) return;
    final item = matches.first;
    if (item.isLocked) return;

    Future<void> leave() => item.category == DiscoverCategory.groupSessions
        ? ref
              .read(groupSessionsWriteServiceProvider)
              .leave(sessionId: id, uid: uid)
        : ref.read(eventsWriteServiceProvider).leave(eventId: id, uid: uid);

    Future<void> join() => item.category == DiscoverCategory.groupSessions
        ? ref
              .read(groupSessionsWriteServiceProvider)
              .join(sessionId: id, uid: uid)
        : ref.read(eventsWriteServiceProvider).join(eventId: id, uid: uid);

    // Önceki sürüm join() hatasını (kontenjan doldu, network vb.) sessizce
    // yutuyordu — üye "Katılıyorum"a basıyor, hiçbir şey olmuyordu, neden
    // olduğunu hiç öğrenemiyordu. Artık hata [DiscoverPanel]'e kadar
    // yükseliyor, orada kısa bir mesaj olarak gösteriliyor.
    if (item.joined) {
      await leave();
    } else {
      if (item.isFull) throw StateError('Kontenjan doldu.');
      await join();
    }
  }
}
