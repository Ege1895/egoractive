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

  /// [trainerIds]/[trainerNames] opsiyonel — birden fazla antrenör
  /// atanabilir (`duetMemberNames`'teki gibi denormalize bir liste).
  /// `trainerName` (tekil, eski) alanı geriye dönük uyumluluk için
  /// (`admin_group_sessions_controller.dart`/`discover_controller.dart`
  /// hâlâ bunu okuyor) isimlerin virgülle birleştirilmiş hâlini taşımaya
  /// devam ediyor — antrenör atanmadıysa boş string.
  Future<void> createGroupSession({
    required String gymId,
    required String title,
    required String description,
    required List<String> trainerIds,
    required List<String> trainerNames,
    required String studioName,
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
    required bool onlineBookingEnabled,
  }) async {
    await FirebaseFirestore.instance.collection('groupSessions').add({
      'gymId': gymId,
      'title': title,
      'description': description,
      'trainerIds': trainerIds,
      'trainerNames': trainerNames,
      'trainerName': trainerNames.join(', '),
      'studioName': studioName,
      'startTime': Timestamp.fromDate(startTime),
      'durationMinutes': durationMinutes,
      'capacity': capacity,
      'onlineBookingEnabled': onlineBookingEnabled,
      'attendeeIds': <String>[],
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Admin'in düzenleme ekranından (bkz. `create_group_session_panel.dart`
  /// edit modu) tek bir mevcut dersi günceller — "Tekrarla" burada geçerli
  /// değil, her doküman kendi başına düzenlenir.
  Future<void> updateGroupSession({
    required String groupSessionId,
    required String title,
    required String description,
    required List<String> trainerIds,
    required List<String> trainerNames,
    required String studioName,
    required DateTime startTime,
    required int durationMinutes,
    required int capacity,
    required bool onlineBookingEnabled,
  }) {
    return FirebaseFirestore.instance
        .collection('groupSessions')
        .doc(groupSessionId)
        .update({
          'title': title,
          'description': description,
          'trainerIds': trainerIds,
          'trainerNames': trainerNames,
          'trainerName': trainerNames.join(', '),
          'studioName': studioName,
          'startTime': Timestamp.fromDate(startTime),
          'durationMinutes': durationMinutes,
          'capacity': capacity,
          'onlineBookingEnabled': onlineBookingEnabled,
        });
  }

  /// Ders listeden kaldırılmaz — `status: cancelled` ile işaretlenir, admin
  /// ekranında iptal rozetiyle listelenmeye devam eder; üye/antrenör
  /// Keşfet akışından ise filtrelenir (bkz. `discover_controller.dart`).
  /// Grup dersleri seans hakkı düşmediği için (bkz. `createGroupSession`)
  /// bir iade/kota işlemi gerekmiyor, sade bir durum güncellemesi yeterli.
  Future<void> cancelGroupSession(String groupSessionId) {
    return FirebaseFirestore.instance
        .collection('groupSessions')
        .doc(groupSessionId)
        .update({'status': 'cancelled'});
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
