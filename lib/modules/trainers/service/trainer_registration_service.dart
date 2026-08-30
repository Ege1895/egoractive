import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trainer_registration_service.g.dart';

/// [TrainerInfoPanel]'in "kendi bilgilerini düzenle" akışı — `member_registration_service.dart`'taki
/// `phoneNumberIsTaken`/`updateOwnInfo` ile aynı desen.
class TrainerRegistrationService {
  const TrainerRegistrationService();

  Future<bool> phoneNumberIsTaken(String phoneNumber) async {
    final callable = FirebaseFunctions.instance.httpsCallable(
      'checkPhoneAvailable',
    );
    final result = await callable.call<Map<String, dynamic>>({
      'phoneNumber': phoneNumber,
    });
    return result.data['available'] != true;
  }

  Future<void> updateOwnInfo({
    required String trainerId,
    required String name,
    required String phoneNumber,
  }) {
    return FirebaseFirestore.instance.collection('users').doc(trainerId).update(
      {
        'name': name,
        'nameLower': name.toLowerCase(),
        'phoneNumber': phoneNumber,
      },
    );
  }
}

@riverpod
TrainerRegistrationService trainerRegistrationService(
  TrainerRegistrationServiceRef ref,
) => const TrainerRegistrationService();
