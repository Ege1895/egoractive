import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_registration_service.g.dart';

/// F2-2 — üye ekleme: `users` koleksiyonuna `role: member` dokümanı yazar.
class MemberRegistrationService {
  const MemberRegistrationService();

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
  }) async {
    final doc = await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'member',
      'gymId': gymId,
      'trainerId': trainerId,
      'trainerName': trainerName,
    });
    return doc.id;
  }
}

@riverpod
MemberRegistrationService memberRegistrationService(MemberRegistrationServiceRef ref) {
  return const MemberRegistrationService();
}
