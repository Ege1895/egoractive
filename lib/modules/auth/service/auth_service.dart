import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../notifications/service/push_notification_service.dart';
import '../domain/auth_login_exception.dart';
import '../domain/otp_exception.dart';
import '../repository/auth_repository.dart';

part 'auth_service.g.dart';

/// Egoractive Authentication Sistemi — telefon/email + email OTP, tek
/// authentication yöntemi (SMS OTP, şifre, PIN, trusted device, Apple/Google
/// Sign-In kullanılmıyor). `deleteAccount`/`signOut` F2-8'den değişmeden
/// kalıyor.
class AuthService {
  const AuthService();

  /// F1-10'un yerini alan ilk adım — telefon ya da email ile kullanıcı
  /// bulunur, kayıtlı email'e OTP gönderilir. `needsEmailSetup:true` dönerse
  /// (telefonla giriş + hesabın email'i boş) henüz OTP gönderilmemiştir,
  /// çağıran taraf `sendEmailSetupOtp`'a geçer.
  Future<StartLoginResult> startLogin({
    required String identifierType,
    required String value,
  }) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('startLogin');
      final result = await callable.call<Map<String, dynamic>>({
        'identifierType': identifierType,
        'value': value,
      });
      return (
        needsEmailSetup: result.data['needsEmailSetup'] == true,
        uid: result.data['uid'] as String,
        email: result.data['email'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      throw AuthLoginException(_loginReasonForCode(e.code));
    } catch (_) {
      throw const AuthLoginException(AuthLoginErrorReason.generic);
    }
  }

  Future<void> verifyLoginOtp({
    required String uid,
    required String code,
  }) async {
    final token = await _callVerify('verifyLoginOtp', {
      'uid': uid,
      'code': code,
    });
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }

  Future<void> sendEmailSetupOtp({
    required String uid,
    required String email,
  }) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendEmailSetupOtp')
          .call<void>({'uid': uid, 'email': email});
    } on FirebaseFunctionsException catch (e) {
      throw OtpException(_sendReasonForCode(e.code));
    } catch (_) {
      throw const OtpException(OtpErrorReason.generic);
    }
  }

  Future<void> verifyEmailSetupOtp({
    required String uid,
    required String code,
  }) async {
    final token = await _callVerify('verifyEmailSetupOtp', {
      'uid': uid,
      'code': code,
    });
    await FirebaseAuth.instance.signInWithCustomToken(token);
  }

  Future<void> sendEmailChangeOtp(String newEmail) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('sendEmailChangeOtp')
          .call<void>({'newEmail': newEmail});
    } on FirebaseFunctionsException catch (e) {
      throw OtpException(_sendReasonForCode(e.code));
    } catch (_) {
      throw const OtpException(OtpErrorReason.generic);
    }
  }

  Future<void> verifyEmailChangeOtp(String code) async {
    try {
      await FirebaseFunctions.instance
          .httpsCallable('verifyEmailChangeOtp')
          .call<void>({'code': code});
    } on FirebaseFunctionsException catch (e) {
      throw OtpException(_verifyReasonForCode(e.code));
    } catch (_) {
      throw const OtpException(OtpErrorReason.generic);
    }
  }

  Future<void> deleteAccount() async {
    await FirebaseFunctions.instance
        .httpsCallable('deleteAccount')
        .call<void>();
    await FirebaseAuth.instance.signOut();
  }

  /// Çıkmadan ÖNCE bu cihazın push token'ı hesabın dokümanından siliniyor —
  /// sıra önemli, `users/{uid}` yazması imzalı oturum gerektiriyor. Aksi
  /// halde token dokümanda kalıyor ve cihaz, çıkış yapıldıktan sonra da o
  /// hesabın bildirimlerini almaya devam ediyordu.
  Future<void> signOut() async {
    await PushNotificationService.removeTokenForCurrentUser();
    await FirebaseAuth.instance.signOut();
  }

  Future<String> _callVerify(String name, Map<String, dynamic> data) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable(name)
          .call<Map<String, dynamic>>(data);
      return result.data['token'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw OtpException(_verifyReasonForCode(e.code));
    } catch (_) {
      throw const OtpException(OtpErrorReason.generic);
    }
  }

  AuthLoginErrorReason _loginReasonForCode(String code) {
    switch (code) {
      case 'not-found':
        return AuthLoginErrorReason.notFound;
      case 'resource-exhausted':
        return AuthLoginErrorReason.rateLimited;
      case 'failed-precondition':
        return AuthLoginErrorReason.subscriptionInactive;
      default:
        return AuthLoginErrorReason.generic;
    }
  }

  OtpErrorReason _verifyReasonForCode(String code) {
    switch (code) {
      case 'invalid-argument':
        return OtpErrorReason.invalidCode;
      case 'deadline-exceeded':
        return OtpErrorReason.expired;
      case 'resource-exhausted':
        return OtpErrorReason.tooManyAttempts;
      default:
        return OtpErrorReason.generic;
    }
  }

  OtpErrorReason _sendReasonForCode(String code) {
    switch (code) {
      case 'already-exists':
        return OtpErrorReason.emailTaken;
      case 'resource-exhausted':
        return OtpErrorReason.tooManyAttempts;
      default:
        return OtpErrorReason.generic;
    }
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) => const AuthService();
