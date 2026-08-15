import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/send_notification_exception.dart';
import '../domain/send_notification_form.dart';
import '../service/send_notification_service.dart';

part 'send_notification_controller.g.dart';

const _rateLimitedMessage = 'Saatlik bildirim gönderme limitine ulaştın, biraz sonra tekrar dene.';
const _genericErrorMessage = 'Bildirim gönderilemedi, tekrar dener misin?';

/// F6-4 — `sendManualNotification` Cloud Function'ını çağırır.
@riverpod
class SendNotificationController extends _$SendNotificationController {
  @override
  SendNotificationForm build() => const SendNotificationForm();

  void setTargetType(NotificationTargetType type) => state = state.copyWith(targetType: type);

  void selectMember(String id, String name) => state = state.copyWith(targetMemberId: id, targetMemberName: name);

  void updateTitle(String value) => state = state.copyWith(title: value);

  void updateMessage(String value) => state = state.copyWith(message: value);

  Future<void> send() async {
    if (state.title.trim().isEmpty || state.message.trim().isEmpty || state.isSending) return;
    if (state.targetType == NotificationTargetType.singleMember && state.targetMemberId == null) return;

    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await ref.read(sendNotificationServiceProvider).send(
            targetType: state.targetType,
            targetMemberId: state.targetMemberId,
            title: state.title.trim(),
            message: state.message.trim(),
          );
      state = state.copyWith(isSending: false, sent: true);
    } on SendNotificationException catch (e) {
      state = state.copyWith(
        isSending: false,
        errorMessage: e.reason == SendNotificationErrorReason.rateLimited ? _rateLimitedMessage : _genericErrorMessage,
      );
    }
  }

  void reset() => state = build();
}
