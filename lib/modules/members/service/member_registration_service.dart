import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../domain/new_member_form.dart';

part 'member_registration_service.g.dart';

/// F2-2 — üye ekleme: `users` koleksiyonuna `role: member` dokümanı yazar.
class MemberRegistrationService {
  const MemberRegistrationService(this._analytics);

  final AnalyticsService _analytics;

  Future<bool> phoneNumberIsTaken(String phoneNumber) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
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
    MemberGender? gender,
  }) async {
    final doc = await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'member',
      'gymId': gymId,
      'trainerId': trainerId,
      'trainerName': trainerName,
      if (gender != null) 'gender': gender.name,
    });
    await _analytics.logEvent(
      AnalyticsEvent.membershipCreated,
      parameters: {'gym_id': gymId, 'trainer_id': trainerId},
    );
    return doc.id;
  }
}

@riverpod
MemberRegistrationService memberRegistrationService(MemberRegistrationServiceRef ref) {
  return MemberRegistrationService(ref.watch(analyticsServiceProvider));
}
