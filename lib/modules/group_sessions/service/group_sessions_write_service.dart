import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/services/capacity_service.dart';

part 'group_sessions_write_service.g.dart';

/// F4-2 — `groupSessions/{id}` üzerinde oluşturma + katılım/ayrılma.
/// Kontenjan kontrolü F4-3'te `CapacityService`'e taşındı (etkinliklerle
/// ortak) — bu servis sadece Firestore koleksiyon/doküman yolunu bilir.
class GroupSessionsWriteService {
  const GroupSessionsWriteService(this._capacityService);

  final CapacityService _capacityService;

  Future<void> createGroupSession({
    required String gymId,
    required String title,
    required String trainerName,
    required String studioName,
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
    required bool onlineBookingEnabled,
  }) async {
    await FirebaseFirestore.instance.collection('groupSessions').add({
      'gymId': gymId,
      'title': title,
      'trainerName': trainerName,
      'studioName': studioName,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'capacity': capacity,
      'onlineBookingEnabled': onlineBookingEnabled,
      'attendeeIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> join({required String sessionId, required String uid}) {
    return _capacityService.join(
      ref: FirebaseFirestore.instance
          .collection('groupSessions')
          .doc(sessionId),
      uid: uid,
    );
  }

  Future<void> leave({required String sessionId, required String uid}) {
    return _capacityService.leave(
      ref: FirebaseFirestore.instance
          .collection('groupSessions')
          .doc(sessionId),
      uid: uid,
    );
  }
}

@riverpod
GroupSessionsWriteService groupSessionsWriteService(
  GroupSessionsWriteServiceRef ref,
) => GroupSessionsWriteService(ref.watch(capacityServiceProvider));
