import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';

part 'session_completion_service.g.dart';

/// F3-5 — antrenörün "Tamamlandı"/"Üye gelmedi" onayı.
class SessionCompletionService {
  const SessionCompletionService(this._analytics);

  final AnalyticsService _analytics;

  /// Antrenörün İLK kez "tamamlandı" onayı (firestore.rules'taki
  /// isCompletingOwnSession() sadece status=='planned' iken izin verir —
  /// bu yüzden antrenör bir seansı sadece BİR KERE setleyebilir). Admin'in
  /// sonradan düzeltmesi [setAttendance] ile aynı yoldan geçer, admin'in
  /// yazma izni durum kısıtına bağlı değildir.
  Future<void> markCompleted({
    required String sessionId,
    required String memberId,
  }) => setAttendance(sessionId: sessionId, memberId: memberId, attended: true);

  /// Antrenörün İLK kez "üye gelmedi" onayı — bkz. [markCompleted].
  Future<void> markAbsent({
    required String sessionId,
    required String memberId,
  }) =>
      setAttendance(sessionId: sessionId, memberId: memberId, attended: false);

  /// F3-5 + admin düzeltmesi — bir seansı "geldi"/"gelmedi" olarak
  /// setler ya da (admin için) daha önce setlenmiş bir değeri düzeltir.
  /// `remainingSessions` burada değişmez — seans hakkı artık OLUŞTURULDUĞU
  /// anda düşülüyor ([SessionsWriteService.createSession]), iptalde geri
  /// veriliyor ([SessionsWriteService.cancelSession]). Tamamlanma/no-show
  /// durumu sadece raporlama amaçlı, kotayı etkilemiyor — üye rezervasyonu
  /// yaptığında hakkı zaten harcanmış sayılıyor, gelip gelmemesi bunu
  /// değiştirmiyor.
  Future<void> setAttendance({
    required String sessionId,
    required String memberId,
    required bool attended,
  }) async {
    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({'status': 'completed', 'attended': attended});

    if (attended) {
      await _analytics.logEvent(
        AnalyticsEvent.sessionCompleted,
        parameters: {'session_id': sessionId},
      );
    }
  }
}

@riverpod
SessionCompletionService sessionCompletionService(
  SessionCompletionServiceRef ref,
) {
  return SessionCompletionService(ref.watch(analyticsServiceProvider));
}
