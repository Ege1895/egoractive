import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/otp_purpose.dart';
import '../service/auth_service.dart';

part 'auth_repository.g.dart';

abstract interface class AuthRepository {
  Future<StartLoginResult> startLogin({
    required String identifierType,
    required String value,
  });
  Future<void> verifyLoginOtp({required String uid, required String code});
  Future<void> sendEmailSetupOtp({required String uid, required String email});
  Future<void> verifyEmailSetupOtp({required String uid, required String code});
  Future<void> sendEmailChangeOtp(String newEmail);
  Future<void> verifyEmailChangeOtp(String code);
  Future<void> deleteAccount();
  Future<void> signOut();
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Future<StartLoginResult> startLogin({
    required String identifierType,
    required String value,
  }) => _service.startLogin(identifierType: identifierType, value: value);

  @override
  Future<void> verifyLoginOtp({required String uid, required String code}) =>
      _service.verifyLoginOtp(uid: uid, code: code);

  @override
  Future<void> sendEmailSetupOtp({
    required String uid,
    required String email,
  }) => _service.sendEmailSetupOtp(uid: uid, email: email);

  @override
  Future<void> verifyEmailSetupOtp({
    required String uid,
    required String code,
  }) => _service.verifyEmailSetupOtp(uid: uid, code: code);

  @override
  Future<void> sendEmailChangeOtp(String newEmail) =>
      _service.sendEmailChangeOtp(newEmail);

  @override
  Future<void> verifyEmailChangeOtp(String code) =>
      _service.verifyEmailChangeOtp(code);

  @override
  Future<void> deleteAccount() => _service.deleteAccount();

  @override
  Future<void> signOut() => _service.signOut();
}

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(authServiceProvider));
}

/// `startLogin`'in sonucu — `needsEmailSetup` true ise henüz OTP
/// gönderilmemiştir, client [otp_purpose.dart]'daki `activation` akışına
/// geçer (bkz. Egoractive Authentication Sistemi §5).
typedef StartLoginResult = ({bool needsEmailSetup, String uid, String? email});

/// Egoractive Authentication Sistemi §6 — app açılışında mevcut authenticated
/// hesabın email alanı boş mu diye tek seferlik kontrol. Email yalnızca
/// [OtpPurpose.activation]/[OtpPurpose.emailChange] doğrulaması sonrası
/// (Cloud Function tarafından) yazıldığı için canlı bir dinleyici yerine
/// tek seferlik `get()` yeterli — `EmailSetupPanel` doğrulama başarılı
/// olunca `ref.invalidate(appAccessProvider)` ile bu kontrolü elle tazeler.
@riverpod
Future<String?> currentUserEmail(CurrentUserEmailRef ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null) return null;
  final snap = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final email = snap.data()?['email'];
  return email is String && email.isNotEmpty ? email : null;
}
