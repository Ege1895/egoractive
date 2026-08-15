/// `sendManualNotification` callable'ından dönen bilinen hata kodları.
enum SendNotificationErrorReason { rateLimited, generic }

/// [SendNotificationService.send] bu istisnayı fırlatır; [SendNotificationController]
/// [reason]'ı kullanıcıya gösterilecek metne çevirir.
class SendNotificationException implements Exception {
  const SendNotificationException(this.reason);

  final SendNotificationErrorReason reason;
}
