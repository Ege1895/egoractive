import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/perf/perf_trace.dart';

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
  }) {
    return _createSessions(
      gymId: gymId,
      trainerId: trainerId,
      trainerName: trainerName,
      members: [(id: memberId, name: memberName)],
      startTime: startTime,
    );
  }

  /// Düet ders — aynı antrenör/saat için birden fazla üyeye AYNI ANDA
  /// (tek transaction'da, hep ya da hiç) seans atar; her üyenin kendi
  /// `sessions/{sessionId}` dokümanı olur (mevcut tüm okuma tarafı —
  /// katılım onayı, tamamlama, raporlar — tek üyeli şemayı zaten
  /// bekliyor, o yüzden şema değişmiyor), ama hepsi aynı `duetGroupId`'yi
  /// taşır ve birbirinin adını `duetMemberNames`'te görür ki takvim/liste
  /// ekranları isterse grup olarak gösterebilsin.
  Future<void> createDuetSession({
    required String gymId,
    required String trainerId,
    required String trainerName,
    required List<({String id, String name})> members,
    required DateTime startTime,
  }) {
    if (members.length < 2) {
      throw ArgumentError('Düet ders en az 2 üye gerektirir.');
    }
    return _createSessions(
      gymId: gymId,
      trainerId: trainerId,
      trainerName: trainerName,
      members: members,
      startTime: startTime,
    );
  }

  Future<void> _createSessions({
    required String gymId,
    required String trainerId,
    required String trainerName,
    required List<({String id, String name})> members,
    required DateTime startTime,
  }) async {
    // F10-1 — "Seans oluşturma" ölçümü. Bu akış hiç Cloud Function
    // kullanmıyor (doğrudan Firestore), yani bildirilen ~60 sn cold
    // start'la AÇIKLANAMIYOR. Çakışma sorgusu ile transaction ayrı ayrı
    // ölçülüyor ki darboğazın hangisi olduğu görülebilsin.
    PerfTrace.begin('AKIS_seans_olustur_toplam');
    PerfTrace.begin('AKIS_seans_cakisma_sorgusu');
    final hasConflict = await _trainerHasConflict(gymId, trainerId, startTime);
    PerfTrace.end('AKIS_seans_cakisma_sorgusu');
    if (hasConflict) {
      PerfTrace.end('AKIS_seans_olustur_toplam');
      throw TrainerConflictException(trainerName);
    }
    final endTime = startTime.add(
      const Duration(minutes: sessionDefaultDurationMinutes),
    );
    final firestore = FirebaseFirestore.instance;
    final isDuet = members.length > 1;
    // Grubu birbirine bağlamak için paylaşılan bir id — henüz yazılmamış
    // bir doc referansının id'si, gerçek bir seans dokümanına karşılık
    // gelmiyor, sadece ortak anahtar olarak kullanılıyor.
    final duetGroupId = isDuet
        ? firestore.collection('sessions').doc().id
        : null;
    final memberNames = members.map((m) => m.name).toList(growable: false);
    final memberRefs = members
        .map((m) => firestore.collection('users').doc(m.id))
        .toList(growable: false);

    // Seans hakkı, seans OLUŞTURULDUĞUNDA düşülür (tamamlanma onayında
    // değil) — üyenin kotası her zaman "rezerve edilmiş" seans sayısını
    // yansıtmalı. Aynı transaction içinde okunup düşülüyor ki eşzamanlı
    // iki oluşturma isteği aynı son hakkı iki kez tüketemesin. Düet ders
    // için TÜM üyelerin hakkı yeterli olmalı — biri yetersizse grubun
    // tamamı (hiçbiri) oluşturulmaz (transaction atomik).
    //
    // `plannedSessionsCount`, `remainingSessions`'ın tam tersi bir sayaç:
    // henüz planlanmamış "havuz" değil, ŞU AN takvimde duran (planned,
    // henüz tamamlanmamış/iptal edilmemiş) seans sayısı. Üyeler listesinde
    // gösterilen "Kalan ders" ikisinin toplamı — sadece gerçekten
    // tamamlanmış dersler düşülüyor (bkz. admin_member_summary_mapper.dart).
    PerfTrace.begin('AKIS_seans_transaction');
    await firestore.runTransaction((transaction) async {
      // Firestore transaction kuralı: tüm okumalar yazmalardan önce olmalı
      // — bu yüzden önce hepsi okunuyor, kota kontrolü ve yazmalar sonra.
      final memberSnapshots = await Future.wait(
        memberRefs.map(transaction.get),
      );

      for (var i = 0; i < members.length; i++) {
        final remaining =
            (memberSnapshots[i].data()?['remainingSessions'] as num?)
                ?.toInt() ??
            0;
        if (remaining <= 0) {
          throw InsufficientSessionsException(members[i].name);
        }
      }

      for (var i = 0; i < members.length; i++) {
        final remaining =
            (memberSnapshots[i].data()?['remainingSessions'] as num?)
                ?.toInt() ??
            0;
        final planned =
            (memberSnapshots[i].data()?['plannedSessionsCount'] as num?)
                ?.toInt() ??
            0;
        final sessionRef = firestore.collection('sessions').doc();
        transaction.set(sessionRef, {
          'gymId': gymId,
          'trainerId': trainerId,
          'trainerName': trainerName,
          'memberId': members[i].id,
          'memberName': members[i].name,
          'startTime': Timestamp.fromDate(startTime),
          'endTime': Timestamp.fromDate(endTime),
          'status': 'planned',
          'confirmationRequested': false,
          'completionPushSent': false,
          'createdAt': FieldValue.serverTimestamp(),
          'sessionType': isDuet ? 'duet' : 'individual',
          if (isDuet) 'duetGroupId': duetGroupId,
          if (isDuet) 'duetMemberNames': memberNames,
        });
        transaction.update(memberRefs[i], {
          'remainingSessions': remaining - 1,
          'plannedSessionsCount': planned + 1,
        });
      }
    });
    PerfTrace.end('AKIS_seans_transaction');
    PerfTrace.end('AKIS_seans_olustur_toplam');
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
          excludeSessionIds: {sessionId},
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

  /// F7-x — takvimde tek bir slota indirgenen bir düet dersin TÜM üye
  /// dokümanlarını birlikte erteler. Çakışma kontrolü kendi düet
  /// grubundaki diğer üyelerin dokümanlarını (aynı antrenör, aynı eski
  /// saat) yanlışlıkla "çakışma" saymasın diye hepsi `excludeSessionIds`'e
  /// veriliyor.
  Future<void> rescheduleDuetSession(
    List<String> sessionIds,
    DateTime newStartTime,
  ) async {
    if (sessionIds.isEmpty) return;
    final firestore = FirebaseFirestore.instance;
    final currentDoc = await firestore
        .collection('sessions')
        .doc(sessionIds.first)
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
          excludeSessionIds: sessionIds.toSet(),
        )) {
      throw TrainerConflictException(trainerName);
    }
    final newEndTime = newStartTime.add(
      const Duration(minutes: sessionDefaultDurationMinutes),
    );
    final batch = firestore.batch();
    for (final id in sessionIds) {
      batch.update(firestore.collection('sessions').doc(id), {
        'startTime': Timestamp.fromDate(newStartTime),
        'endTime': Timestamp.fromDate(newEndTime),
        'confirmationRequested': false,
        'completionPushSent': false,
      });
    }
    await batch.commit();
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
    Set<String> excludeSessionIds = const {},
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('gymId', isEqualTo: gymId)
        .where('trainerId', isEqualTo: trainerId)
        .where('startTime', isEqualTo: Timestamp.fromDate(startTime))
        .get();
    return snapshot.docs.any(
      (doc) =>
          !excludeSessionIds.contains(doc.id) &&
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
      var planned = 0;
      if (shouldRefund) {
        memberRef = firestore.collection('users').doc(memberId);
        final memberSnapshot = await transaction.get(memberRef);
        remaining =
            (memberSnapshot.data()?['remainingSessions'] as num?)?.toInt() ?? 0;
        planned =
            (memberSnapshot.data()?['plannedSessionsCount'] as num?)?.toInt() ??
            0;
      }

      transaction.update(sessionRef, {'status': 'cancelled'});
      if (memberRef != null) {
        transaction.update(memberRef, {
          'remainingSessions': remaining + 1,
          'plannedSessionsCount': planned > 0 ? planned - 1 : 0,
        });
      }
    });

    await _analytics.logEvent(
      AnalyticsEvent.sessionCancelled,
      parameters: {'session_id': sessionId},
    );
  }

  /// F7-x — takvimde tek bir slota indirgenen bir düet dersin TÜM üye
  /// dokümanlarını birlikte iptal eder, her üyenin paketine hakkını geri
  /// verir. Firestore transaction kuralı gereği (tüm okumalar tüm
  /// yazmalardan önce olmalı) önce hepsi okunuyor, sonra hepsi yazılıyor.
  Future<void> cancelDuetSession(List<String> sessionIds) async {
    if (sessionIds.isEmpty) return;
    final firestore = FirebaseFirestore.instance;

    await firestore.runTransaction((transaction) async {
      final sessionRefs = sessionIds
          .map((id) => firestore.collection('sessions').doc(id))
          .toList();
      final sessionSnapshots = await Future.wait(
        sessionRefs.map(transaction.get),
      );

      final memberRefunds = <String, ({int remaining, int planned})>{};
      for (final snapshot in sessionSnapshots) {
        final status = snapshot.data()?['status'] as String?;
        final memberId = snapshot.data()?['memberId'] as String?;
        if (status != 'planned' || memberId == null) continue;
        if (memberRefunds.containsKey(memberId)) continue;
        final memberSnapshot = await transaction.get(
          firestore.collection('users').doc(memberId),
        );
        memberRefunds[memberId] = (
          remaining:
              (memberSnapshot.data()?['remainingSessions'] as num?)
                  ?.toInt() ??
              0,
          planned:
              (memberSnapshot.data()?['plannedSessionsCount'] as num?)
                  ?.toInt() ??
              0,
        );
      }

      for (final snapshot in sessionSnapshots) {
        transaction.update(snapshot.reference, {'status': 'cancelled'});
      }
      memberRefunds.forEach((memberId, counts) {
        transaction.update(firestore.collection('users').doc(memberId), {
          'remainingSessions': counts.remaining + 1,
          'plannedSessionsCount': counts.planned > 0 ? counts.planned - 1 : 0,
        });
      });
    });

    for (final sessionId in sessionIds) {
      await _analytics.logEvent(
        AnalyticsEvent.sessionCancelled,
        parameters: {'session_id': sessionId},
      );
    }
  }
}

@riverpod
SessionsWriteService sessionsWriteService(SessionsWriteServiceRef ref) {
  return SessionsWriteService(ref.watch(analyticsServiceProvider));
}
