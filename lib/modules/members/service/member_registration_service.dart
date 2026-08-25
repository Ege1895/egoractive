import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../domain/new_member_form.dart';

part 'member_registration_service.g.dart';

/// F2-2 — üye ekleme: `users` koleksiyonuna `role: member` dokümanı yazar.
class MemberRegistrationService {
  const MemberRegistrationService(this._analytics);

  final AnalyticsService _analytics;

  /// `phoneNumber` tüm `users` koleksiyonunda (salon gözetmeksizin) global
  /// benzersiz olmalı — girişte `requestCustomToken` numarayla eşleşen ilk
  /// dokümanı kullanıyor. Bu yüzden doğrudan client-side bir Firestore
  /// sorgusuyla kontrol edilemez: `firestore.rules`'taki `users` okuma
  /// kuralı `resource.data.gymId == myGymId()` gerektirir ve gymId filtresi
  /// olmayan bir `list` sorgusu Firestore tarafından asla provably-safe
  /// sayılmaz — her zaman permission-denied ile reddedilir. Bunun yerine
  /// Admin SDK ile kuralları atlayan `checkPhoneAvailable` callable'ı
  /// çağrılır (başka salonun üye verisini client'a sızdırmadan sadece bir
  /// boolean döner).
  Future<bool> phoneNumberIsTaken(String phoneNumber) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'checkPhoneAvailable',
    );
    final result = await callable.call<Map<String, dynamic>>({
      'phoneNumber': phoneNumber,
    });
    return result.data['available'] != true;
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
}

@riverpod
MemberRegistrationService memberRegistrationService(
  MemberRegistrationServiceRef ref,
) {
  return MemberRegistrationService(ref.watch(analyticsServiceProvider));
}
