import 'package:freezed_annotation/freezed_annotation.dart';

import 'auth_login_exception.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default('') String phoneDigits,
    @Default(false) bool isRequestingLogin,
    String? loginErrorMessage,

    /// Hatanın telefon alanına mı (notFound) yoksa genele mi (rate limit,
    /// network) ait olduğunu ayırt eder — [PhoneLoginPanel] buna göre
    /// hatayı field-seviyeli mi yoksa genel bir satır olarak mı gösterir.
    AuthLoginErrorReason? loginErrorReason,
    @Default(false) bool deleteAccountAcknowledged,
    @Default(false) bool isDeletingAccount,
    String? deleteAccountErrorMessage,
  }) = _AuthState;

  const AuthState._();

  /// Türkiye numarası 10 hane (5XX XXX XX XX) — +90 ayrı gösteriliyor.
  bool get isPhoneComplete => phoneDigits.length == 10;
}
