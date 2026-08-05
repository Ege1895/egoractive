/// `requestCustomToken` callable'ından dönen bilinen hata kodları.
enum AuthLoginErrorReason { notFound, rateLimited, generic }

/// [AuthService.requestLogin] bu istisnayı fırlatır; [AuthRepository]/[AuthController]
/// katmanı [reason]'ı kullanıcıya gösterilecek Remote Config metnine çevirir.
class AuthLoginException implements Exception {
  const AuthLoginException(this.reason);

  final AuthLoginErrorReason reason;
}
