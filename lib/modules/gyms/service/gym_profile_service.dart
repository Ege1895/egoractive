import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';

part 'gym_profile_service.g.dart';

/// `gyms/{gymId}` dokümanının `name`/`city`/`phone`/`address` alanları —
/// [signupGymAdmin] callable'ı tarafından salon oluşturulurken yazılır (bkz.
/// `functions/src/callable/signup-gym-admin.ts`), burada [GymInfoPanel]
/// (mevcut salonu düzenleme) için okunur/güncellenir.
class GymProfileService {
  const GymProfileService();

  Stream<GymProfile> watchProfile(String gymId) {
    return FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          final phone = (data?['phone'] as String?) ?? '';
          return GymProfile(
            name: (data?['name'] as String?) ?? '',
            city: (data?['city'] as String?) ?? '',
            // F8-4 — Firestore'da artık tam E.164 tutuluyor
            // (AppPhoneField/signupGymAdmin), TR'ye özel bir dönüşüm yok.
            phone: phone,
            isPhoneValid: phone.isNotEmpty,
            address: (data?['address'] as String?) ?? '',
            logoUrl: (data?['logoUrl'] as String?) ?? '',
          );
        });
  }

  Future<void> saveProfile(String gymId, GymProfile profile) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).update({
      'name': profile.name,
      'city': profile.city,
      'phone': profile.phone,
      'address': profile.address,
    });
  }
}

@riverpod
GymProfileService gymProfileService(GymProfileServiceRef ref) =>
    const GymProfileService();
