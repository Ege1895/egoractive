import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/utils/phone_lookup.dart';

part 'trainer_registration_service.g.dart';

/// [TrainerInfoPanel]'in "kendi bilgilerini düzenle" akışı — `member_registration_service.dart`'taki
/// `phoneNumberIsTaken`/`updateOwnInfo` ile aynı desen (bkz. oradaki
/// `phoneIndex` notu — F2-2 perf, cold start'tan kaçınmak için).
class TrainerRegistrationService {
  const TrainerRegistrationService();

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

  /// Admin · Antrenör Detayı > "Antrenörü sil". SOFT-DELETE: `users/{uid}`
  /// dokümanı ve antrenörün ürettiği hiçbir veri (seanslar, grup dersleri,
  /// üye atamaları, aylık istatistikler) SİLİNMEZ — sadece hesap giriş
  /// yapamaz hale gelir ve antrenör listelerinden çıkar, böylece geçmiş
  /// raporlar bozulmaz. Firebase Auth hesabını da devre dışı bırakmak
  /// Admin SDK gerektirdiği için Cloud Function üzerinden yapılır.
  Future<void> deactivateTrainer(String trainerId) async {
    await FirebaseFunctions.instance
        .httpsCallable('deactivateTrainer')
        .call<void>({'trainerId': trainerId});
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
