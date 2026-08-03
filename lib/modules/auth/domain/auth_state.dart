import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default('') String phoneDigits,
    @Default(false) bool isRequestingLogin,
    @Default(false) bool deleteAccountAcknowledged,
    @Default(false) bool isDeletingAccount,
    @Default(0) int selectedAvatarIndex,
    @Default(true) bool sessionReminderEnabled,
  }) = _AuthState;

  const AuthState._();

  /// Türkiye numarası 10 hane (5XX XXX XX XX) — +90 ayrı gösteriliyor.
  bool get isPhoneComplete => phoneDigits.length == 10;
}
