import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../service/auth_service.dart';

part 'auth_repository.g.dart';

abstract interface class AuthRepository {
  Future<void> login(String phoneDigits);
  Future<void> deleteAccount();
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Future<void> login(String phoneDigits) => _service.requestLogin(phoneDigits);

  @override
  Future<void> deleteAccount() => _service.deleteAccount();

  @override
  Future<void> signOut() => _service.signOut();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(authServiceProvider));
}
