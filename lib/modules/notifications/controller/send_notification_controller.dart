import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/send_notification_form.dart';

part 'send_notification_controller.g.dart';

/// Mock kontrolcü — F2'de gerçek FCM/Cloud Functions gönderimine bağlanacak.
@riverpod
class SendNotificationController extends _$SendNotificationController {
  @override
  SendNotificationForm build() => const SendNotificationForm();

  void setTargetType(NotificationTargetType type) => state = state.copyWith(targetType: type);

  void selectMember(String id, String name) => state = state.copyWith(targetMemberId: id, targetMemberName: name);

  void updateTitle(String value) => state = state.copyWith(title: value);

  void updateMessage(String value) => state = state.copyWith(message: value);

  void send() => state = state.copyWith(sent: true);

  void reset() => state = build();
}
