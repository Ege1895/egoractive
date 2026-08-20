import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../../members/controller/admin_members_controller.dart';
import '../domain/admin_trainer_summary.dart';
import '../domain/admin_trainer_summary_mapper.dart';
import '../repository/admin_trainers_repository.dart';

part 'admin_trainers_controller.g.dart';

@riverpod
Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _trainerDocsForGym(
  _TrainerDocsForGymRef ref,
  String gymId,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('gymId', isEqualTo: gymId)
      .where('role', isEqualTo: 'trainer')
      .snapshots()
      .map((snapshot) => snapshot.docs);
}

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz — bu
/// durumda [AdminTrainersController] mock listeye düşer (bkz.
/// [AdminMembersController]'daki aynı desen).
@riverpod
class AdminTrainersController extends _$AdminTrainersController {
  @override
  List<AdminTrainerSummary> build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      return ref.watch(adminTrainersRepositoryProvider).loadTrainers();
    }
    final docs = ref.watch(_trainerDocsForGymProvider(gymId)).valueOrNull;
    if (docs == null) return const [];

    // `memberCount`, trainer dokümanında tutulmuyor — üye dokümanlarındaki
    // denormalize `trainerName` alanıyla sayılıyor (aynı üye listesi zaten
    // AdminMembersController üzerinden canlı izleniyor).
    final members = ref.watch(adminMembersControllerProvider);
    final countByTrainerName = <String, int>{};
    for (final member in members) {
      if (member.trainerName.isEmpty) continue;
      countByTrainerName[member.trainerName] =
          (countByTrainerName[member.trainerName] ?? 0) + 1;
    }

    return docs
        .map(
          (doc) => adminTrainerSummaryFromDoc(
            doc,
            memberCount:
                countByTrainerName[(doc.data()['name'] as String?)?.trim()] ??
                0,
          ),
        )
        .toList();
  }

  /// `users` koleksiyonuna `role: trainer` dokümanı yazar — aynı `users`
  /// koleksiyonu ve aynı yazma kuralları [MemberRegistrationService]
  /// tarafından üye eklerken de kullanılıyor (bkz. firestore.rules
  /// `match /users/{uid}`, admin için role'e özel bir kısıt yok).
  Future<void> addTrainer({
    required String name,
    required String phoneNumber,
    required List<String> specialties,
  }) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      throw StateError('Aktif salon bulunamadı.');
    }
    await FirebaseFirestore.instance.collection('users').add({
      'name': name,
      'phoneNumber': phoneNumber,
      'role': 'trainer',
      'gymId': gymId,
      'specialties': specialties,
    });
  }

  Future<void> updateTrainer({
    required String id,
    required String name,
    required String phoneNumber,
    required List<String> specialties,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(id).update({
      'name': name,
      'phoneNumber': phoneNumber,
      'specialties': specialties,
    });
  }
}
