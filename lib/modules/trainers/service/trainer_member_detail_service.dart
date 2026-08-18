import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'trainer_member_detail_service.g.dart';

/// `users/{memberId}` dokümanını gerçek zamanlı izler.
class TrainerMemberDetailService {
  const TrainerMemberDetailService();

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchMemberDoc(
    String memberId,
  ) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(memberId)
        .snapshots();
  }
}

@riverpod
TrainerMemberDetailService trainerMemberDetailService(
  TrainerMemberDetailServiceRef ref,
) {
  return const TrainerMemberDetailService();
}
