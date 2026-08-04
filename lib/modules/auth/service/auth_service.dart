import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_service.g.dart';

/// Mock servis — henüz gerçek Firebase bağlantısı yok (F1-10/F2-8'de
/// `request-custom-token` ve `delete-account` callable'larına bağlanacak).
class AuthService {
  const AuthService();

  Future<void> requestLogin(String phoneDigits) {
    return Future<void>.delayed(const Duration(seconds: 2));
  }

  Future<void> deleteAccount() {
    return Future<void>.delayed(const Duration(seconds: 2));
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) => const AuthService();
