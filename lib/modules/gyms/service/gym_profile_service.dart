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
          return GymProfile(
            name: (data?['name'] as String?) ?? '',
            city: (data?['city'] as String?) ?? '',
            // Firestore'da '+90' önekiyle tutuluyor (signupGymAdmin) —
            // GymProfileController.updatePhone ile aynı temsili (sadece rakam,
            // en fazla 10 hane) korumak için önek burada soyuluyor.
            phone: _stripToDigits((data?['phone'] as String?) ?? ''),
            address: (data?['address'] as String?) ?? '',
          );
        });
  }

  Future<void> saveProfile(String gymId, GymProfile profile) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).update({
      'name': profile.name,
      'city': profile.city,
      'phone': '+90${profile.phone}',
      'address': profile.address,
    });
  }

  String _stripToDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final withoutCountryCode = digits.startsWith('90') && digits.length > 10
        ? digits.substring(2)
        : digits;
    return withoutCountryCode.length > 10
        ? withoutCountryCode.substring(0, 10)
        : withoutCountryCode;
  }
}

@riverpod
GymProfileService gymProfileService(GymProfileServiceRef ref) =>
    const GymProfileService();
