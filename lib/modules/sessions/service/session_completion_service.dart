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
  ///
  /// `plannedSessionsCount` burada düşülür — bu seans artık "takvimde
  /// bekleyen" değil, tamamlanmış sayılıyor. Sadece session hâlâ
  /// `planned` durumundaysa düşülür (transaction içinde okunuyor); admin
  /// aynı seansın attendance'ını sonradan düzeltirse (completed→completed)
  /// tekrar düşülmez.
  Future<void> setAttendance({
    required String sessionId,
    required String memberId,
    required bool attended,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final sessionRef = firestore.collection('sessions').doc(sessionId);
    final memberRef = firestore.collection('users').doc(memberId);

    await firestore.runTransaction((transaction) async {
      // Firestore transaction kuralı: tüm okumalar tüm yazmalardan önce
      // yapılmalı — bu yüzden memberRef koşullu de olsa write'lardan
      // önce okunuyor.
      final sessionSnapshot = await transaction.get(sessionRef);
      final wasPlanned = sessionSnapshot.data()?['status'] == 'planned';
      final memberSnapshot = wasPlanned
          ? await transaction.get(memberRef)
          : null;

      transaction.update(sessionRef, {
        'status': 'completed',
        'attended': attended,
      });
      if (memberSnapshot != null) {
        final planned =
            (memberSnapshot.data()?['plannedSessionsCount'] as num?)
                ?.toInt() ??
            0;
        transaction.update(memberRef, {
          'plannedSessionsCount': planned > 0 ? planned - 1 : 0,
        });
      }
    });

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
