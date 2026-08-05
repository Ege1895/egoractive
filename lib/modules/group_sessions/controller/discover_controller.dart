import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/discover_item.dart';
import '../repository/discover_repository.dart';
import '../service/group_sessions_write_service.dart';

part 'discover_controller.g.dart';

const _monthAbbrev = {
  1: 'Oca', 2: 'Şub', 3: 'Mar', 4: 'Nis', 5: 'May', 6: 'Haz',
  7: 'Tem', 8: 'Ağu', 9: 'Eyl', 10: 'Eki', 11: 'Kas', 12: 'Ara',
};
const _weekdayNames = {1: 'Pazartesi', 2: 'Salı', 3: 'Çarşamba', 4: 'Perşembe', 5: 'Cuma', 6: 'Cumartesi', 7: 'Pazar'};

@riverpod
Stream<List<DiscoverItem>> _groupSessionsForGym(_GroupSessionsForGymRef ref, String gymId, String myUid) {
  final lockHours = ref.watch(remoteConfigServiceProvider).groupSessionLockHoursBefore;
  final now = Timestamp.now();
  return FirebaseFirestore.instance
      .collection('groupSessions')
      .where('gymId', isEqualTo: gymId)
      .where('startTime', isGreaterThanOrEqualTo: now)
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => _toDiscoverItem(doc, myUid, lockHours)).toList());
}

DiscoverItem _toDiscoverItem(QueryDocumentSnapshot<Map<String, dynamic>> doc, String myUid, int lockHours) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final attendeeIds = List<String>.from(data['attendeeIds'] as List? ?? const []);
  final durationMinutes = (data['durationMinutes'] as num?)?.toInt() ?? 0;
  final time = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  return DiscoverItem(
    id: doc.id,
    category: DiscoverCategory.groupSessions,
    day: startTime.day.toString().padLeft(2, '0'),
    month: _monthAbbrev[startTime.month] ?? '',
    title: (data['title'] as String?) ?? '',
    meta: '${(data['trainerName'] as String?) ?? ''} · ${_weekdayNames[startTime.weekday]} $time · $durationMinutes dk',
    taken: attendeeIds.length,
    capacity: (data['capacity'] as num?)?.toInt() ?? 0,
    joined: attendeeIds.contains(myUid),
    startTime: startTime,
    lockHoursBefore: lockHours,
  );
}

/// F4-2 — üyenin salonunda ileri tarihli, gerçek zamanlı grup dersleri.
/// Etkinlikler (F4-3) hâlâ mock — sadece grup dersleri kategorisi gerçeğe
/// bağlandı.
@riverpod
class DiscoverController extends _$DiscoverController {
  @override
  List<DiscoverItem> build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    final mock = ref.watch(discoverRepositoryProvider).loadItems();
    if (gymId == null || uid == null) return mock;

    final groupSessions = ref.watch(_groupSessionsForGymProvider(gymId, uid)).valueOrNull;
    if (groupSessions == null) return mock;

    final events = mock.where((i) => i.category == DiscoverCategory.events).toList();
    return [...groupSessions, ...events];
  }

  Future<void> toggleJoin(String id) async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    final item = state.where((i) => i.id == id).firstOrNullFallback();
    if (uid == null || item == null || item.isLocked) return;

    final service = ref.read(groupSessionsWriteServiceProvider);
    if (item.joined) {
      await service.leave(sessionId: id, uid: uid);
    } else {
      if (item.isFull) return;
      try {
        await service.join(sessionId: id, uid: uid);
      } catch (_) {
        // Kontenjan tam o an dolduysa (yarış durumu) sessizce yok say —
        // gerçek zamanlı stream zaten güncel dolu durumunu yansıtacak.
      }
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? firstOrNullFallback() {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
