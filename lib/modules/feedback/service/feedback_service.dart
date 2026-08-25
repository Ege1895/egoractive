import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_service.g.dart';

/// F5-4 — `feedback` koleksiyonuna yazar. Antrenör adı, üyenin kendi
/// `users/{uid}` dokümanında zaten denormalize duran `trainerName`
/// alanından okunur — antrenörün KENDİ dokümanını ayrıca okumaya
/// çalışmak (önceki sürüm) `firestore.rules`'ta üyenin başka bir
/// kullanıcı dokümanını okumasına izin veren bir madde olmadığı için
/// PERMISSION_DENIED ile gönderimin tamamını başarısız ediyordu.
class FeedbackService {
  const FeedbackService();

  Future<void> submit({required int rating, required String comment}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final memberDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final memberData = memberDoc.data();
    final gymId = memberData?['gymId'] as String?;
    if (gymId == null) return;

    await FirebaseFirestore.instance.collection('feedback').add({
      'gymId': gymId,
      'memberId': user.uid,
      'memberName': (memberData?['name'] as String?) ?? '',
      'trainerId': memberData?['trainerId'] as String?,
      'trainerName': (memberData?['trainerName'] as String?) ?? '',
      'stars': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) =>
    const FeedbackService();
