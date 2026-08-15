import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_service.g.dart';

/// F5-4 — `feedback` koleksiyonuna yazar. Antrenör adı/ismi, üyenin kendi
/// `users/{uid}` dokümanından (gymId, name, trainerId) ve antrenörün
/// dokümanından (name) okunup denormalize edilir — admin listesi ekstra
/// join yapmadan gösterebiliyor.
class FeedbackService {
  const FeedbackService();

  Future<void> submit({required int rating, required String comment}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final memberDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final memberData = memberDoc.data();
    final gymId = memberData?['gymId'] as String?;
    if (gymId == null) return;

    final trainerId = memberData?['trainerId'] as String?;
    var trainerName = '';
    if (trainerId != null && trainerId.isNotEmpty) {
      final trainerDoc = await FirebaseFirestore.instance.collection('users').doc(trainerId).get();
      trainerName = (trainerDoc.data()?['name'] as String?) ?? '';
    }

    await FirebaseFirestore.instance.collection('feedback').add({
      'gymId': gymId,
      'memberId': user.uid,
      'memberName': (memberData?['name'] as String?) ?? '',
      'trainerId': trainerId,
      'trainerName': trainerName,
      'stars': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) => const FeedbackService();
