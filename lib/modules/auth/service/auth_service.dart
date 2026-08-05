import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth_login_exception.dart';

part 'auth_service.g.dart';

/// F1-10 — `requestCustomToken` callable'ını çağırıp dönen token'la
/// `signInWithCustomToken` yapar. F2-8 — `deleteAccount` callable'ını çağırıp
/// (Auth kaydı + users/{uid} silinir) yerel oturumu da kapatır.
class AuthService {
  const AuthService();

  Future<void> requestLogin(String phoneDigits) async {
    final phoneNumber = '+90$phoneDigits';
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('requestCustomToken');
      final result = await callable.call<Map<String, dynamic>>({'phoneNumber': phoneNumber});
      final token = result.data['token'] as String;
      await FirebaseAuth.instance.signInWithCustomToken(token);
    } on FirebaseFunctionsException catch (e) {
      throw AuthLoginException(_reasonForCode(e.code));
    } catch (_) {
      // Beklenmedik bir hata (ağ, plugin, FirebaseAuthException vb.) —
      // kullanıcıya yine de anlamlı bir mesaj gösterilsin, çökme olmasın.
      throw const AuthLoginException(AuthLoginErrorReason.generic);
    }
  }

  Future<void> deleteAccount() async {
    await FirebaseFunctions.instance.httpsCallable('deleteAccount').call<void>();
    await FirebaseAuth.instance.signOut();
  }

  AuthLoginErrorReason _reasonForCode(String code) {
    switch (code) {
      case 'not-found':
        return AuthLoginErrorReason.notFound;
      case 'resource-exhausted':
        return AuthLoginErrorReason.rateLimited;
      default:
        return AuthLoginErrorReason.generic;
    }
  }
}

@riverpod
AuthService authService(AuthServiceRef ref) => const AuthService();
