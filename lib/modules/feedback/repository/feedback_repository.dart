import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../service/feedback_service.dart';

part 'feedback_repository.g.dart';

abstract interface class FeedbackRepository {
  Future<void> submit({required int rating, required String comment});
}

class FeedbackRepositoryImpl implements FeedbackRepository {
  const FeedbackRepositoryImpl(this._service);

  final FeedbackService _service;

  @override
  Future<void> submit({required int rating, required String comment}) =>
      _service.submit(rating: rating, comment: comment);
}

@riverpod
FeedbackRepository feedbackRepository(FeedbackRepositoryRef ref) {
  return FeedbackRepositoryImpl(ref.watch(feedbackServiceProvider));
}
