import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../shared/utils/phone_lookup.dart';
import '../domain/new_member_form.dart';

part 'member_registration_service.g.dart';

/// F2-2 — üye ekleme: `users` koleksiyonuna `role: member` dokümanı yazar.
class MemberRegistrationService {
  const MemberRegistrationService(this._analytics);

  final AnalyticsService _analytics;

  /// F2-2 perf — eskiden Admin SDK ile kuralları atlayan `checkPhoneAvailable`
  /// callable'ına gidiyordu; bu callable soğuk başlarsa (Cloud Run
  /// scale-to-zero) "Kaydet"e basınca tek başına 20-30+ saniye ekleyebiliyordu
  /// (kullanıcı raporu: ~1 dakikaya varan donma). `phoneIndex/{phoneNumber}`
  /// (bkz. `on-user-write-sync-phone-index.ts` trigger'ı) sadece varlık
  /// kontrolü için var ve herkese okumaya açık — Cloud Function'a hiç
  /// gitmeden, doğrudan ucuz bir point-read'le (cold start riski yok)
  /// kontrol edilir.
  Future<bool> phoneNumberIsTaken(String phoneNumber) async {
    for (final candidate in phoneLookupCandidates(phoneNumber)) {
      final doc = await FirebaseFirestore.instance
          .collection('phoneIndex')
          .doc(candidate)
          .get();
      if (doc.exists) return true;
    }
    return false;
  }

  /// Oluşturulan `users/{uid}` dokümanının id'sini döner — F3-2'deki paket
  /// satış akışı bu id'yi `memberPackages` dokümanında referans olarak
  /// kullanır.
  Future<String> registerMember({
    required String name,
    required String phoneNumber,
    required String gymId,
    required String trainerId,
    required String trainerName,
    required DateTime registeredAt,
    MemberGender? gender,
    required bool canConfirmAttendance,
  }) async {
    final doc = await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'nameLower': name.toLowerCase(),
      'phoneNumber': phoneNumber,
      'role': 'member',
      'gymId': gymId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      // Admin eskiden beri gelen bir üyeyi geçmiş bir tarihle kaydedebilir
      // diye bugünün tarihi yerine formdan seçilen tarih yazılır (bkz.
      // MemberInfoPanel "Kayıt tarihi" alanı).
      'createdAt': Timestamp.fromDate(registeredAt),
      if (gender != null) 'gender': gender.name,
      'canConfirmAttendance': canConfirmAttendance,
    });
    await _analytics.logEvent(
      AnalyticsEvent.membershipCreated,
      parameters: {'gym_id': gymId, 'trainer_id': trainerId},
    );
    return doc.id;
  }

  /// [MemberInfoPanel]'in mevcut üye düzenleme modu — `trainerId`/
  /// `trainerName`/`gender` sadece kullanıcı bu oturumda gerçekten
  /// değiştirdiyse (null değilse) güncellenir, aksi halde dokümandaki mevcut
  /// değer korunur.
  Future<void> updateMember({
    required String memberId,
    required String name,
    required String phoneNumber,
    String? trainerId,
    String? trainerName,
    MemberGender? gender,
    required bool canConfirmAttendance,
  }) {
    return FirebaseFirestore.instance.collection('users').doc(memberId).update({
      'name': name,
      'nameLower': name.toLowerCase(),
      'phoneNumber': phoneNumber,
      if (trainerId != null) 'trainerId': trainerId,
      if (trainerName != null) 'trainerName': trainerName,
      if (gender != null) 'gender': gender.name,
      'canConfirmAttendance': canConfirmAttendance,
    });
  }

  /// [MemberSelfInfoPanel] — üyenin KENDİ bilgilerini (ad/soyad/telefon)
  /// düzenlemesi. `updateMember`'dan farklı olarak `trainerId`/`gender`/
  /// `canConfirmAttendance` gibi admin'e özel alanlara hiç dokunmuyor —
  /// üye kendi dokümanında yalnızca bu üç alanı değiştirebilir
  /// (`firestore.rules`'taki `users/{uid}` update kuralı zaten
  /// `request.auth.uid == uid` için kısıtsız izin veriyor).
  Future<void> updateOwnInfo({
    required String memberId,
    required String name,
    required String phoneNumber,
  }) {
    return FirebaseFirestore.instance.collection('users').doc(memberId).update({
      'name': name,
      'nameLower': name.toLowerCase(),
      'phoneNumber': phoneNumber,
    });
  }
}

@riverpod
MemberRegistrationService memberRegistrationService(
  MemberRegistrationServiceRef ref,
) {
  return MemberRegistrationService(ref.watch(analyticsServiceProvider));
}
