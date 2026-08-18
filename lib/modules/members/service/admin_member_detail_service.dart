import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_member_detail_service.g.dart';

/// `users/{memberId}` dokümanını gerçek zamanlı izler.
class AdminMemberDetailService {
  const AdminMemberDetailService();

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
AdminMemberDetailService adminMemberDetailService(
  AdminMemberDetailServiceRef ref,
) => const AdminMemberDetailService();
