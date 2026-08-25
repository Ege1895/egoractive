import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';

part 'sessions_write_service.g.dart';

/// Bir antrenöre aynı gün aynı saatte ikinci bir seans atanmaya
/// çalışıldığında fırlatılır — UI bunu genel "oluşturulamadı" hatasından
/// ayırıp antrenörün o saatte dolu olduğunu açıkça göstermeli.
class TrainerConflictException implements Exception {
  const TrainerConflictException(this.trainerName);

  final String trainerName;
}

/// Üyenin paketinde kalan seans hakkı 0 veya altındayken yeni seans
/// oluşturulmaya çalışıldığında fırlatılır.
class InsufficientSessionsException implements Exception {
  const InsufficientSessionsException(this.memberName);

  final String memberName;
}

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
    if (await _trainerHasConflict(gymId, trainerId, startTime)) {
      throw TrainerConflictException(trainerName);
    }
    final endTime = startTime.add(
      const Duration(minutes: sessionDefaultDurationMinutes),
    );
    final firestore = FirebaseFirestore.instance;
    final memberRef = firestore.collection('users').doc(memberId);
    final sessionRef = firestore.collection('sessions').doc();

    // Seans hakkı, seans OLUŞTURULDUĞUNDA düşülür (tamamlanma onayında
    // değil) — üyenin kotası her zaman "rezerve edilmiş" seans sayısını
    // yansıtmalı. Aynı transaction içinde okunup düşülüyor ki eşzamanlı
    // iki oluşturma isteği aynı son hakkı iki kez tüketemesin.
    await firestore.runTransaction((transaction) async {
      final memberSnapshot = await transaction.get(memberRef);
      final remaining =
          (memberSnapshot.data()?['remainingSessions'] as num?)?.toInt() ?? 0;
      if (remaining <= 0) {
        throw InsufficientSessionsException(memberName);
      }
      transaction.set(sessionRef, {
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
      transaction.update(memberRef, {'remainingSessions': remaining - 1});
    });
  }

  Future<void> rescheduleSession(
    String sessionId,
    DateTime newStartTime,
  ) async {
    final currentDoc = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .get();
    final gymId = currentDoc.data()?['gymId'] as String?;
    final trainerId = currentDoc.data()?['trainerId'] as String?;
    final trainerName = currentDoc.data()?['trainerName'] as String? ?? '';
    if (gymId != null &&
        trainerId != null &&
        await _trainerHasConflict(
          gymId,
          trainerId,
          newStartTime,
          excludeSessionId: sessionId,
        )) {
      throw TrainerConflictException(trainerName);
    }
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

  /// Bir antrenörün aynı gün aynı saatte ikinci bir seansa atanmasını
  /// engeller — önceden bu kontrol hiç yapılmıyordu, aynı antrenöre aynı
  /// saatte birden fazla seans atanabiliyordu.
  ///
  /// `gymId` filtresi olmadan bu sorgu `firestore.rules`'taki
  /// `resource.data.gymId == myGymId()` kuralı yüzünden her zaman
  /// permission-denied ile reddediliyordu — bu da her seans oluşturma
  /// denemesinde (antrenör gerçekte müsaitken bile) yanlışlıkla "antrenör bu
  /// saatte dolu" hatası olarak görünüyordu.
  Future<bool> _trainerHasConflict(
    String gymId,
    String trainerId,
    DateTime startTime, {
    String? excludeSessionId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('gymId', isEqualTo: gymId)
        .where('trainerId', isEqualTo: trainerId)
        .where('startTime', isEqualTo: Timestamp.fromDate(startTime))
        .get();
    return snapshot.docs.any(
      (doc) =>
          doc.id != excludeSessionId &&
          (doc.data()['status'] as String?) != 'cancelled',
    );
  }

  /// İptal edilen seans hâlâ `planned` durumundaysa (henüz tamamlanmamışsa)
  /// oluşturmada düşülen seans hakkı üyeye geri veriliyor — zaten
  /// `completed` bir seans iptal edilemez ki bu durum oluşsun (bkz.
  /// firestore.rules), ama ileride biri bunu değiştirirse çift iade
  /// yapılmasın diye yine de kontrol ediliyor.
  Future<void> cancelSession(String sessionId) async {
    final firestore = FirebaseFirestore.instance;
    final sessionRef = firestore.collection('sessions').doc(sessionId);

    await firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final status = sessionSnapshot.data()?['status'] as String?;
      final memberId = sessionSnapshot.data()?['memberId'] as String?;
      final shouldRefund = status == 'planned' && memberId != null;

      DocumentReference<Map<String, dynamic>>? memberRef;
      var remaining = 0;
      if (shouldRefund) {
        memberRef = firestore.collection('users').doc(memberId);
        final memberSnapshot = await transaction.get(memberRef);
        remaining =
            (memberSnapshot.data()?['remainingSessions'] as num?)?.toInt() ??
            0;
      }

      transaction.update(sessionRef, {'status': 'cancelled'});
      if (memberRef != null) {
        transaction.update(memberRef, {'remainingSessions': remaining + 1});
      }
    });

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
