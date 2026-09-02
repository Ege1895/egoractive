import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_login_exception.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    /// F8-2 — global telefon numarası desteği. E.164 formatında
    /// (`+905324187605`) tam numara — [AppPhoneField] tarafından üretilir,
    /// artık TR'ye özel 10 hane/`+90` varsayımı yok.
    @Default('') String phoneE164,

    /// [AppPhoneField]'ın kendi `phone_numbers_parser` tabanlı bölgesel
    /// doğrulamasından gelir (`PhoneNumber.isValid()`).
    @Default(false) bool isPhoneValid,
    @Default('') String emailInput,
    @Default(false) bool isRequestingLogin,
    String? loginErrorMessage,

    /// Hatanın identifier alanına mı (notFound — telefon ya da email) yoksa
    /// genele mi (rate limit, network) ait olduğunu ayırt eder —
    /// [PhoneLoginPanel]/[EmailLoginPanel] buna göre hatayı field-seviyeli
    /// mi yoksa genel bir satır olarak mı gösterir.
    AuthLoginErrorReason? loginErrorReason,
    @Default(false) bool deleteAccountAcknowledged,
    @Default(false) bool isDeletingAccount,
    String? deleteAccountErrorMessage,
  }) = _AuthState;

  const AuthState._();

  bool get isPhoneComplete => isPhoneValid;

  bool get isEmailComplete =>
      emailInput.contains('@') &&
      emailInput.trim().length == emailInput.length &&
      emailInput.length > 3;
}
