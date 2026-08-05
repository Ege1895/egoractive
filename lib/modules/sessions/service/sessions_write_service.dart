import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sessions_write_service.g.dart';

/// F3-3 — `sessions/{sessionId}` üzerinde oluşturma/iptal/erteleme.
/// Antrenör/üye için 24 saatlik iptal penceresi `firestore.rules`'ta
/// zorlanır (bu servis sadece admin ekranlarından çağrılıyor, admin için
/// deadline yok).
class SessionsWriteService {
  const SessionsWriteService();

  Future<void> createSession({
    required String gymId,
    required String trainerId,
    required String trainerName,
    required String memberId,
    required String memberName,
    required DateTime startTime,
  }) async {
    await FirebaseFirestore.instance.collection('sessions').add({
      'gymId': gymId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'memberId': memberId,
      'memberName': memberName,
      'startTime': Timestamp.fromDate(startTime),
      'status': 'planned',
      'confirmationRequested': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rescheduleSession(String sessionId, DateTime newStartTime) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({'startTime': Timestamp.fromDate(newStartTime)});
  }

  Future<void> cancelSession(String sessionId) async {
    await FirebaseFirestore.instance.collection('sessions').doc(sessionId).update({'status': 'cancelled'});
  }
}

@riverpod
SessionsWriteService sessionsWriteService(SessionsWriteServiceRef ref) => const SessionsWriteService();
