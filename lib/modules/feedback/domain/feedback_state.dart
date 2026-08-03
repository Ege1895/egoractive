import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_state.freezed.dart';

@freezed
class FeedbackState with _$FeedbackState {
  const factory FeedbackState({
    @Default(0) int rating,
    @Default('') String comment,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSubmitted,
  }) = _FeedbackState;
}
