import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';

part 'sessions_write_service.g.dart';

/// F3-5 — seans süresi henüz stüdyo bazlı yapılandırılabilir değil, sabit
/// 60 dakika kabul ediliyor. `endTime` bu süre üzerinden hesaplanıp
/// kaydediliyor — F3-5'teki tamamlama hatırlatma fonksiyonu bunu kullanır.
const sessionDefaultDurationMinutes = 60;

/// F3-3 — `sessions/{sessionId}` üzerinde oluşturma/iptal/erteleme.
/// Antrenör/üye için 24 saatlik iptal penceresi `firestore.rules`'ta
/// zorlanır (bu servis sadece admin ekranlarından çağrılıyor, admin için
/// deadline yok).
class SessionsWriteService {
  const SessionsWriteService(this._analytics);

  final AnalyticsService _analytics;

  Future<void> createSession({
    required String gymId,
    required String trainerId,
    required String trainerName,
    required String memberId,
    required String memberName,
    required DateTime startTime,
  }) async {
    final endTime = startTime.add(
      const Duration(minutes: sessionDefaultDurationMinutes),
    );
    await FirebaseFirestore.instance.collection('sessions').add({
      'gymId': gymId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'memberId': memberId,
      'memberName': memberName,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'status': 'planned',
      'confirmationRequested': false,
      'completionPushSent': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rescheduleSession(
    String sessionId,
    DateTime newStartTime,
  ) async {
    final newEndTime = newStartTime.add(
      const Duration(minutes: sessionDefaultDurationMinutes),
    );
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({
          'startTime': Timestamp.fromDate(newStartTime),
          'endTime': Timestamp.fromDate(newEndTime),
          'confirmationRequested': false,
          'completionPushSent': false,
        });
  }

  Future<void> cancelSession(String sessionId) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({'status': 'cancelled'});
    await _analytics.logEvent(
      AnalyticsEvent.sessionCancelled,
      parameters: {'session_id': sessionId},
    );
  }
}

@riverpod
SessionsWriteService sessionsWriteService(SessionsWriteServiceRef ref) {
  return SessionsWriteService(ref.watch(analyticsServiceProvider));
}
