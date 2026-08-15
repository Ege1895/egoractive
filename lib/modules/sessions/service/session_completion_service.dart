import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';

part 'session_completion_service.g.dart';

/// F3-5 — antrenörün "Tamamlandı"/"Üye gelmedi" onayı.
class SessionCompletionService {
  const SessionCompletionService(this._analytics);

  final AnalyticsService _analytics;

  /// `remainingSessions` azaltma işlemi bir transaction içinde yapılır —
  /// aynı üyenin başka bir seansı eşzamanlı tamamlanırsa iki yazma da
  /// birbirinin üstüne yazmadan, güncel değeri okuyup düşürür (kabul
  /// kriteri: race condition'a karşı korumalı).
  Future<void> markCompleted({required String sessionId, required String memberId}) async {
    final firestore = FirebaseFirestore.instance;
    final sessionRef = firestore.collection('sessions').doc(sessionId);
    final memberRef = firestore.collection('users').doc(memberId);

    await firestore.runTransaction((transaction) async {
      final memberSnapshot = await transaction.get(memberRef);
      final remaining = (memberSnapshot.data()?['remainingSessions'] as num?)?.toInt() ?? 0;

      transaction.update(sessionRef, {'status': 'completed', 'attended': true});
      transaction.update(memberRef, {'remainingSessions': (remaining - 1).clamp(0, remaining)});
    });

    await _analytics.logEvent(AnalyticsEvent.sessionCompleted, parameters: {'session_id': sessionId});
  }

  /// Üye gelmediyse ders kalan seans sayısından düşülmez — session sadece
  /// "tamamlandı/işlendi" olarak kapanır, transaction gerekmez.
  Future<void> markAbsent(String sessionId) {
    return FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({'status': 'completed', 'attended': false});
  }
}

@riverpod
SessionCompletionService sessionCompletionService(SessionCompletionServiceRef ref) {
  return SessionCompletionService(ref.watch(analyticsServiceProvider));
}
