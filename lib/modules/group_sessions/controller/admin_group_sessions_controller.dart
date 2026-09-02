import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/admin_group_session.dart';
import '../repository/admin_group_sessions_repository.dart';
import '../../../shared/utils/date_labels.dart';

part 'admin_group_sessions_controller.g.dart';

@riverpod
Stream<List<AdminGroupSession>> _groupSessionsForGym(
  _GroupSessionsForGymRef ref,
  String gymId,
) {
  final labels = ref.watch(dateLabelsProvider);
  final now = Timestamp.now();
  return FirebaseFirestore.instance
      .collection('groupSessions')
      .where('gymId', isEqualTo: gymId)
      .where('startTime', isGreaterThanOrEqualTo: now)
      .orderBy('startTime')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) => _toAdminGroupSession(doc, labels))
            .toList(),
      );
}

AdminGroupSession _toAdminGroupSession(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
  DateLabels labels,
) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  final attendeeIds = List<String>.from(
    data['attendeeIds'] as List? ?? const [],
  );
  return AdminGroupSession(
    id: doc.id,
    name: (data['title'] as String?) ?? '',
    meta:
        '${(data['trainerName'] as String?) ?? ''} · ${labels.weekdayLong(startTime.weekday)} $time',
    taken: attendeeIds.length,
    capacity: (data['capacity'] as num?)?.toInt() ?? 0,
    isCancelled: (data['status'] as String?) == 'cancelled',
  );
}

/// F4-2 — salonun ileri tarihli, gerçek zamanlı grup dersleri.
@riverpod
class AdminGroupSessionsController extends _$AdminGroupSessionsController {
  @override
  List<AdminGroupSession> build() {
    final gymIdAsync = ref.watch(activeGymIdProvider);
    // activeGymIdProvider ilk izlendiğinde henüz sonuçlanmamış olabilir —
    // bu durum "gerçekten salon yok" ile aynı değil; o ana kadar mock'a
    // düşülürse admin panelinde bir an sahte grup dersi/doluluk gerçekmiş
    // gibi görünür.
    if (gymIdAsync.isLoading) return const [];
    final gymId = gymIdAsync.valueOrNull;
    if (gymId == null) {
      return ref
          .watch(adminGroupSessionsRepositoryProvider)
          .loadGroupSessions();
    }
    return ref.watch(_groupSessionsForGymProvider(gymId)).valueOrNull ??
        const [];
  }
}
