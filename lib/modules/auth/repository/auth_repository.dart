import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // Girişin HEMEN ardından yapılan ilk okuma eksik bir doküman döndürebiliyor.
  // Sebep bir yarış: aynı anda `PushNotificationService._saveToken`,
  // `users/{uid}` dokümanına `set({fcmTokens: ...}, merge: true)` yazıyor.
  // Cihaz bu dokümanı daha önce hiç okumadığı için Firestore'un yerel
  // görünümü o an YALNIZCA o tek alandan ibaret oluyor ve `get()` bu kısmi
  // dokümanı (exists=true, fromCache=false, tek alan) döndürüyor. Sonuç:
  // email'i dolu olan kullanıcı "E-posta adresini ekle" ekranına atılıyordu;
  // uygulama kapatılıp açılınca düzeliyordu (emülatörde üretim buildi ile üç
  // farklı hesapta yeniden üretildi, 2026-10-11).
  //
  // Her kullanıcı dokümanında `role` alanı bulunur; `role` yoksa okunan şey
  // gerçek doküman değildir. O durumda sunucudan yeniden sorulur. Denemeler
  // de sonuç vermezse (gerçekten çevrimdışıyız) eldeki cevapla devam edilir.
  var snap = await doc.get();
  for (
    var attempt = 1;
    attempt <= _userDocReadRetries && _isPartialUserDoc(snap);
    attempt++
  ) {
    debugPrint('[currentUserEmail] kısmi doküman okundu, deneme $attempt');
    await Future<void>.delayed(_userDocReadRetryDelay * attempt);
    try {
      snap = await doc.get(const GetOptions(source: Source.server));
    } on FirebaseException catch (error) {
      debugPrint('[currentUserEmail] sunucu okuması başarısız: ${error.code}');
    }
  }
  return _emailOf(snap);
}

const _userDocReadRetries = 3;
const _userDocReadRetryDelay = Duration(milliseconds: 400);

bool _isPartialUserDoc(DocumentSnapshot<Map<String, dynamic>> snap) =>
    snap.data()?['role'] == null;

String? _emailOf(DocumentSnapshot<Map<String, dynamic>> snap) {
  final email = snap.data()?['email'];
  return email is String && email.isNotEmpty ? email : null;
}
