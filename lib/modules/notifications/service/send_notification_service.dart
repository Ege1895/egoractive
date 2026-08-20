import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/send_notification_exception.dart';
import '../domain/send_notification_form.dart';

part 'send_notification_service.g.dart';

/// F6-4 — `sendManualNotification` callable'ını çağırır (admin, üye/tüm
/// salon için başlık+metin). Fonksiyonun kendi tarafında saatlik gönderim
/// limiti var; `resource-exhausted` kodu [SendNotificationErrorReason.rateLimited]'a çevrilir.
class SendNotificationService {
  const SendNotificationService();

  Future<int> send({
    required NotificationTargetType targetType,
    List<String> targetMemberIds = const [],
    required String title,
    required String message,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable(
        'sendManualNotification',
      );
      final result = await callable.call<Map<String, dynamic>>({
        'targetType': targetType == NotificationTargetType.selectedMembers
            ? 'selectedMembers'
            : 'wholeGym',
        if (targetMemberIds.isNotEmpty) 'targetMemberIds': targetMemberIds,
        'title': title,
        'message': message,
      });
      return result.data['sentCount'] as int;
    } on FirebaseFunctionsException catch (e) {
      throw SendNotificationException(_reasonForCode(e.code));
    } catch (_) {
      throw const SendNotificationException(
        SendNotificationErrorReason.generic,
      );
    }
  }

  SendNotificationErrorReason _reasonForCode(String code) {
    switch (code) {
      case 'resource-exhausted':
        return SendNotificationErrorReason.rateLimited;
      default:
        return SendNotificationErrorReason.generic;
    }
  }
}

@riverpod
SendNotificationService sendNotificationService(
  SendNotificationServiceRef ref,
) => const SendNotificationService();
