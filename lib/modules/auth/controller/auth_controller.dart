import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/remote_config/remote_config_service.dart';
import '../domain/auth_login_exception.dart';
import '../domain/auth_state.dart';
import '../repository/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  /// F8-2 — [AppPhoneField]'dan E.164 + bölgesel doğrulama sonucu gelir.
  /// Numara düzenlenince önceki giriş hatası temizlenir — kullanıcı numarayı
  /// düzeltmeye başladığında eski "bulunamadı" mesajı ekranda asılı kalmasın.
  void setPhone(String e164, {required bool isValid}) {
    state = state.copyWith(
      phoneE164: e164,
      isPhoneValid: isValid,
      loginErrorMessage: null,
      loginErrorReason: null,
    );
  }

  void setEmailInput(String value) {
    state = state.copyWith(
      emailInput: value,
      loginErrorMessage: null,
      loginErrorReason: null,
    );
  }

  /// Egoractive Authentication Sistemi §3/§4 — telefon ya da email ile
  /// giriş akışının ilk adımı. `null` dönerse hata zaten [state]'e yazılmış
  /// demektir (çağıran panel field/genel hatayı gösterir); değer dönerse
  /// çağıran panel `needsEmailSetup`'a göre [EmailSetupPanel] ya da
  /// [OtpVerificationPanel]'i push eder — navigasyon kararı burada değil,
  /// panelde verilir (Controller UI'dan habersiz kalır).
  Future<StartLoginResult?> startLogin({required String identifierType}) async {
    if (state.isRequestingLogin) return null;
    if (identifierType == 'phone' && !state.isPhoneComplete) return null;
    if (identifierType == 'email' && !state.isEmailComplete) return null;

    state = state.copyWith(
      isRequestingLogin: true,
      loginErrorMessage: null,
      loginErrorReason: null,
    );
    final value = identifierType == 'phone'
        ? state.phoneE164
        : state.emailInput.trim();
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .startLogin(identifierType: identifierType, value: value);
      state = state.copyWith(isRequestingLogin: false);
      return result;
    } on AuthLoginException catch (e) {
      state = state.copyWith(
        isRequestingLogin: false,
        loginErrorMessage: _messageFor(e.reason),
        loginErrorReason: e.reason,
      );
      return null;
    }
  }

  void toggleDeleteAcknowledged() {
    state = state.copyWith(
      deleteAccountAcknowledged: !state.deleteAccountAcknowledged,
    );
  }

  /// Başarılıysa hesap silinip `FirebaseAuth.signOut()` çağrılmış olur —
  /// `main.dart`'taki merkezi `appAccessProvider` dinleyicisi auth state
  /// null olduğunda kendiliğinden girişe yönlendirir, çağıran taraf ayrıca
  /// bir navigasyon yapmaz (iki ayrı `replaceRoot`'un yarışa girmesini
  /// önlemek için). Dönen `bool` sadece UI'ın hata/başarı ayrımı için.
  Future<bool> deleteAccount() async {
    if (!state.deleteAccountAcknowledged || state.isDeletingAccount) {
      return false;
    }
    state = state.copyWith(
      isDeletingAccount: true,
      deleteAccountErrorMessage: null,
    );
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = state.copyWith(isDeletingAccount: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isDeletingAccount: false,
        deleteAccountErrorMessage: ref
            .read(remoteConfigServiceProvider)
            .getText(
              RemoteConfigKeys.authDeleteAccountErrorGeneric,
              ref.read(localeControllerProvider),
            ),
      );
      return false;
    }
  }

  /// Oturumu kapatır. UI hemen giriş ekranına döndüğü için local state
  /// senkron sıfırlanıyor; gerçek `FirebaseAuth.signOut()` arkada
  /// tamamlanıyor — aksi halde (önceki sürümde olduğu gibi) Auth oturumu
  /// canlı kalır ve uygulama yeniden açıldığında aynı hesaba otomatik
  /// giriş yapılır.
  void logout() {
    state = const AuthState();
    unawaited(ref.read(authRepositoryProvider).signOut().catchError((_) {}));
  }

  String _messageFor(AuthLoginErrorReason reason) {
    final rc = ref.read(remoteConfigServiceProvider);
    final key = switch (reason) {
      AuthLoginErrorReason.notFound => RemoteConfigKeys.authLoginErrorNotFound,
      AuthLoginErrorReason.rateLimited =>
        RemoteConfigKeys.authLoginErrorRateLimited,
      AuthLoginErrorReason.subscriptionInactive =>
        RemoteConfigKeys.authLoginErrorSubscriptionInactive,
      AuthLoginErrorReason.generic => RemoteConfigKeys.authLoginErrorGeneric,
    };
    return rc.getText(key, ref.read(localeControllerProvider));
  }
}
