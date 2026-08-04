import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/feedback_state.dart';
import '../repository/feedback_repository.dart';

part 'feedback_controller.g.dart';

@riverpod
class FeedbackController extends _$FeedbackController {
  @override
  FeedbackState build() => const FeedbackState();

  void setRating(int rating) {
    state = state.copyWith(rating: rating);
  }

  void setComment(String comment) {
    state = state.copyWith(comment: comment);
  }

  Future<void> submit() async {
    if (state.rating == 0 || state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    await ref.read(feedbackRepositoryProvider).submit(rating: state.rating, comment: state.comment);
    state = state.copyWith(isSubmitting: false, isSubmitted: true);
  }
}
