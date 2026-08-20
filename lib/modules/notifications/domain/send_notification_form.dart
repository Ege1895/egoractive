import 'package:freezed_annotation/freezed_annotation.dart';

part 'send_notification_form.freezed.dart';

enum NotificationTargetType { selectedMembers, wholeGym }

@freezed
class SendNotificationForm with _$SendNotificationForm {
  const factory SendNotificationForm({
    @Default(NotificationTargetType.wholeGym) NotificationTargetType targetType,
    // id -> isim, seçim sırasını korumak için Map yerine LinkedHashMap
    // davranışına sahip Dart'ın varsayılan Map'i kullanılıyor.
    @Default(<String, String>{}) Map<String, String> targetMembers,
    @Default('') String title,
    @Default('') String message,
    @Default(false) bool sent,
    @Default(false) bool isSending,
    String? errorMessage,
  }) = _SendNotificationForm;
}
