import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feedback_service.g.dart';

/// Mock servis — Faz 4'te `feedback/{id}` koleksiyonuna yazacak.
class FeedbackService {
  const FeedbackService();

  Future<void> submit({required int rating, required String comment}) {
    return Future<void>.delayed(const Duration(milliseconds: 900));
  }
}

@riverpod
FeedbackService feedbackService(FeedbackServiceRef ref) => const FeedbackService();
