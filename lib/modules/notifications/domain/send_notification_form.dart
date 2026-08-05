import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_notification_form.freezed.dart';

enum NotificationTargetType { singleMember, wholeGym }

@freezed
class SendNotificationForm with _$SendNotificationForm {
  const factory SendNotificationForm({
    @Default(NotificationTargetType.wholeGym) NotificationTargetType targetType,
    String? targetMemberId,
    String? targetMemberName,
    @Default('') String title,
    @Default('') String message,
    @Default(false) bool sent,
  }) = _SendNotificationForm;
}
