/// OTP gönderme/doğrulama callable'larından (`sendEmailSetupOtp`,
/// `verifyLoginOtp`, `verifyEmailSetupOtp`, `sendEmailChangeOtp`,
/// `verifyEmailChangeOtp`) dönen bilinen hata kodları.
enum OtpErrorReason {
  /// Kod yanlış (`invalid-argument`).
  invalidCode,

  /// Kodun süresi doldu / hiç gönderilmemiş (`deadline-exceeded`).
  expired,

  /// Çok fazla yanlış deneme / çok sık istek (`resource-exhausted`).
  tooManyAttempts,

  /// Email başka bir hesapta zaten kayıtlı (`already-exists`).
  emailTaken,

  generic,
}

class OtpException implements Exception {
  const OtpException(this.reason);

  final OtpErrorReason reason;
}
