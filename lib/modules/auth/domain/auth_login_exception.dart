/// `startLogin` callable'ından dönen bilinen hata kodları.
/// `subscriptionInactive` — Salon Abonelik ve Erişim Akışı: antrenör/üye,
/// salonun aboneliği `trial`/`active` değilken giriş yapamaz.
enum AuthLoginErrorReason {
  notFound,
  rateLimited,
  subscriptionInactive,
  generic,
}

/// [AuthService.startLogin] bu istisnayı fırlatır; [AuthRepository]/[AuthController]
/// katmanı [reason]'ı kullanıcıya gösterilecek Remote Config metnine çevirir.
class AuthLoginException implements Exception {
  const AuthLoginException(this.reason);

  final AuthLoginErrorReason reason;
}
