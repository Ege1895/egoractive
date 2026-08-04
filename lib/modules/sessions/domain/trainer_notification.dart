import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_notification.freezed.dart';

@freezed
class TrainerNotification with _$TrainerNotification {
  const factory TrainerNotification({
    required String id,
    required String title,
    required String body,
    required String memberInitials,
    required String memberName,
    required String sessionMeta,
    required String answerLabel,
    required bool answerIsPositive,
    required String answeredAt,
    required String? note,
  }) = _TrainerNotification;
}
