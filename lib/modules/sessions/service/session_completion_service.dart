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
  /// `remainingSessions`, session'ın ESKİ (varsa) ve YENİ attended
  /// değerleri arasındaki FARKA göre ayarlanır — aynı transaction içinde,
  /// aynı üyenin başka bir seansı eşzamanlı değişirse race condition'a
  /// karşı korumalı:
  /// - İlk kez setleniyorsa (status henüz 'completed' değilse): attended
  ///   true ise -1, false ise değişiklik yok (mevcut davranışla aynı).
  /// - Zaten 'completed' bir seans DÜZELTİLİYORSA (sadece admin
  ///   yazabilir, bkz. firestore.rules): false→true iken -1 (seans şimdi
  ///   tüketildi), true→false iken +1 (seans geri veriliyor), değer
  ///   değişmiyorsa dokunulmaz.
  Future<void> setAttendance({
    required String sessionId,
    required String memberId,
    required bool attended,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final sessionRef = firestore.collection('sessions').doc(sessionId);
    final memberRef = firestore.collection('users').doc(memberId);

    await firestore.runTransaction((transaction) async {
      // Firestore transaction kuralı: tüm read'ler tüm write'lardan önce
      // yapılmalı — bu yüzden session VE member aynı anda, herhangi bir
      // update'ten önce okunuyor.
      final sessionSnapshot = await transaction.get(sessionRef);
      final memberSnapshot = await transaction.get(memberRef);

      final wasCompleted = sessionSnapshot.data()?['status'] == 'completed';
      final wasAttended = sessionSnapshot.data()?['attended'] as bool?;
      final remaining =
          (memberSnapshot.data()?['remainingSessions'] as num?)?.toInt() ?? 0;

      final int delta;
      if (!wasCompleted) {
        delta = attended ? -1 : 0;
      } else if (wasAttended == true && !attended) {
        delta = 1;
      } else if (wasAttended != true && attended) {
        delta = -1;
      } else {
        delta = 0;
      }

      transaction.update(sessionRef, {
        'status': 'completed',
        'attended': attended,
      });
      if (delta != 0) {
        final newRemaining = remaining + delta;
        transaction.update(memberRef, {
          'remainingSessions': newRemaining < 0 ? 0 : newRemaining,
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
