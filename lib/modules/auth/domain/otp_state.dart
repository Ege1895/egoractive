import 'package:freezed_annotation/freezed_annotation.dart';

part 'otp_state.freezed.dart';

@freezed
class OtpState with _$OtpState {
  const factory OtpState({
    @Default('') String code,
    @Default(false) bool isVerifying,
    @Default(false) bool isResending,
    @Default(0) int secondsRemaining,
    String? errorMessage,
  }) = _OtpState;

  const OtpState._();

  bool get canResend => secondsRemaining <= 0 && !isResending;
  bool get isCodeComplete => code.length == 6;
}
