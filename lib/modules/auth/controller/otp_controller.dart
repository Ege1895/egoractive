import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/remote_config/remote_config_service.dart';
import '../domain/otp_exception.dart';
import '../domain/otp_state.dart';

part 'otp_controller.g.dart';

const _resendCooldownSeconds = 60;

/// Egoractive Authentication Sistemi §7 — OTP ekranının purpose'tan bağımsız
/// (login/activation/emailChange) ortak state'i: kod input'u, 60sn
/// TAMAMEN client-side geri sayım, doğrulama/tekrar-gönderme durumları.
/// Hangi callable'ın çağrılacağını bilmez — [verify]/[resend] çağıran
/// panelden bir closure alır, böylece Controller diğer modüllerden/UI'dan
/// habersiz kalır (CLAUDE.md §2.2).
@riverpod
class OtpController extends _$OtpController {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() => _timer?.cancel());
    return const OtpState();
  }

  /// Panel `onPanelShow()`'da bir kez çağırır — ilk OTP zaten gönderilmiş
  /// olarak bu panele geçilir, geri sayım o andan başlar.
  void startCountdown() {
    _timer?.cancel();
    state = state.copyWith(secondsRemaining: _resendCooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining <= 1) {
        _timer?.cancel();
        state = state.copyWith(secondsRemaining: 0);
      } else {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      }
    });
  }

  void setCode(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    state = state.copyWith(
      code: digits.length > 6 ? digits.substring(0, 6) : digits,
      errorMessage: null,
    );
  }

  Future<bool> verify(Future<void> Function(String code) verifyFn) async {
    if (!state.isCodeComplete || state.isVerifying) return false;
    state = state.copyWith(isVerifying: true, errorMessage: null);
    try {
      await verifyFn(state.code);
      state = state.copyWith(isVerifying: false);
      return true;
    } on OtpException catch (e) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: _messageFor(e.reason),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isVerifying: false,
        errorMessage: _messageFor(OtpErrorReason.generic),
      );
      return false;
    }
  }

  Future<void> resend(Future<void> Function() resendFn) async {
    if (!state.canResend) return;
    state = state.copyWith(isResending: true, errorMessage: null, code: '');
    try {
      await resendFn();
      state = state.copyWith(isResending: false);
      startCountdown();
    } on OtpException catch (e) {
      state = state.copyWith(
        isResending: false,
        errorMessage: _messageFor(e.reason),
      );
    } catch (_) {
      state = state.copyWith(
        isResending: false,
        errorMessage: _messageFor(OtpErrorReason.generic),
      );
    }
  }

  String _messageFor(OtpErrorReason reason) {
    final rc = ref.read(remoteConfigServiceProvider);
    final key = switch (reason) {
      OtpErrorReason.invalidCode => RemoteConfigKeys.authOtpInvalidCodeError,
      OtpErrorReason.expired => RemoteConfigKeys.authOtpExpiredError,
      OtpErrorReason.tooManyAttempts =>
        RemoteConfigKeys.authOtpTooManyAttemptsError,
      OtpErrorReason.emailTaken =>
        RemoteConfigKeys.authEmailSetupEmailTakenError,
      OtpErrorReason.generic => RemoteConfigKeys.authOtpGenericError,
    };
    return rc.getText(key, ref.read(localeControllerProvider));
  }
}
