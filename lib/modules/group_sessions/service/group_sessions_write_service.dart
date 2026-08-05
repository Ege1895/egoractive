import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_sessions_write_service.g.dart';

/// F4-2 — `groupSessions/{id}` üzerinde oluşturma + katılım/ayrılma.
class GroupSessionsWriteService {
  const GroupSessionsWriteService();

  Future<void> createGroupSession({
    required String gymId,
    required String title,
    required String trainerName,
    required String studioName,
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
  }) async {
    await FirebaseFirestore.instance.collection('groupSessions').add({
      'gymId': gymId,
      'title': title,
      'trainerName': trainerName,
      'studioName': studioName,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'capacity': capacity,
      'attendeeIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Kontenjan kontrolü bir transaction içinde yapılır — aynı seansa
  /// eşzamanlı gelen katılım isteklerinden, dolulukla çakışanlar
  /// Firestore'un transaction retry mekanizması sayesinde sırayla
  /// işlenir; kontenjan hiçbir zaman aşılmaz (kabul kriteri). Zaten
  /// katılmışsa no-op, kontenjan doluysa hata fırlatır.
  Future<void> join({required String sessionId, required String uid}) async {
    final ref = FirebaseFirestore.instance.collection('groupSessions').doc(sessionId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final data = snapshot.data();
      if (data == null) throw StateError('Seans bulunamadı.');
      final attendeeIds = List<String>.from(data['attendeeIds'] as List? ?? const []);
      if (attendeeIds.contains(uid)) return;
      final capacity = (data['capacity'] as num).toInt();
      if (attendeeIds.length >= capacity) {
        throw StateError('Kontenjan doldu.');
      }
      transaction.update(ref, {'attendeeIds': FieldValue.arrayUnion([uid])});
    });
  }

  Future<void> leave({required String sessionId, required String uid}) async {
    await FirebaseFirestore.instance
        .collection('groupSessions')
        .doc(sessionId)
        .update({'attendeeIds': FieldValue.arrayRemove([uid])});
  }
}

@riverpod
GroupSessionsWriteService groupSessionsWriteService(GroupSessionsWriteServiceRef ref) =>
    const GroupSessionsWriteService();
