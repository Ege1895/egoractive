import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_registration_service.g.dart';

/// F2-2 — üye ekleme: `users` koleksiyonuna `role: member` dokümanı yazar.
/// `trainerId` bilerek boş bırakılır — antrenör ataması ayrı bir akış
/// (F2-2 kapsamı dışı, henüz yapılmadı).
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

  Future<void> registerMember({
    required String name,
    required String phoneNumber,
    required String gymId,
  }) async {
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'member',
      'gymId': gymId,
      'trainerId': '',
    });
  }
}

@riverpod
MemberRegistrationService memberRegistrationService(MemberRegistrationServiceRef ref) {
  return const MemberRegistrationService();
}
