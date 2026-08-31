import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_access.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/otp_controller.dart';
import '../../repository/auth_repository.dart';
import '../../domain/otp_purpose.dart';

/// Ortak 3 · OTP Doğrulama — Egoractive Authentication Sistemi §7/§8. Tüm
/// giriş/aktivasyon/email-değişikliği akışları TEK bu paneli paylaşır;
/// [purpose] hangi callable'ın çağrılacağını ve başarı sonrası ne
/// olacağını belirler:
/// - [OtpPurpose.login]/[OtpPurpose.activation] → doğrulama başarılıysa
///   repository zaten `signInWithCustomToken` yapar; navigasyon
///   `main.dart`'taki merkezi `appAccessProvider` dinleyicisine bırakılır
///   (elle pop/push yok — mevcut `logout()`/`deleteAccount()` deseniyle
///   tutarlı). `appAccessProvider` invalidate edilir ki email/rol durumu
///   hemen yeniden değerlendirilsin.
/// - [OtpPurpose.emailChange] → çağırıcıya (Gym/Member/Trainer info paneli)
///   [onVerified] callback'iyle bırakılır: bu panel sadece pop olur, geri
///   kalan alanların kaydedilmesi çağırıcının sorumluluğundadır.
///
/// Geri butonu HER ZAMAN vardır (§8) — `pop()`, önceki panelin doldurulmuş
/// alanları `PanelStackController`'ın panelleri canlı tutması sayesinde
/// korunur.
class OtpVerificationPanel extends BasePanel {
  const OtpVerificationPanel({
    super.key,
    required this.purpose,
    required this.email,
    this.uid,
    this.onVerified,
  });

  final OtpPurpose purpose;

  /// [OtpPurpose.login]/[OtpPurpose.activation] için zorunlu (backend
  /// unauthenticated çağrılıyor, uid ile hesap belirleniyor).
  /// [OtpPurpose.emailChange] kullanmaz — o çağrı zaten authenticated,
  /// backend `request.auth.uid`'i kullanır.
  final String? uid;
  final String email;

  /// Sadece [OtpPurpose.emailChange] için kullanılır.
  final Future<void> Function()? onVerified;

  @override
  ConsumerState<OtpVerificationPanel> createState() =>
      _OtpVerificationPanelState();
}

class _OtpVerificationPanelState extends BasePanelState<OtpVerificationPanel> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void onPanelShow() {
    // `onPanelShow` senkron olarak `initState` içinden tetiklenebiliyor
    // (panel ilk kez push edildiğinde) — bir provider'ın state'ini widget
    // ağacı build sürerken değiştirmek Riverpod'da yasak, bu yüzden bir
    // sonraki frame'e erteleniyor.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(otpControllerProvider.notifier).startCountdown();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final otpState = ref.watch(otpControllerProvider);
    final otpController = ref.read(otpControllerProvider.notifier);

    if (_codeController.text != otpState.code) {
      _codeController.value = TextEditingValue(
        text: otpState.code,
        selection: TextSelection.collapsed(offset: otpState.code.length),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.md,
            AppSpacing.screenEdge,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBackButton(
                onTap: () =>
                    ref.read(panelStackControllerProvider.notifier).pop(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                ref.watch(rcTextProvider(RemoteConfigKeys.authOtpTitle)),
                style: typography.headingLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ref
                    .watch(rcTextProvider(RemoteConfigKeys.authOtpSubtitle))
                    .replaceAll('{email}', widget.email),
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  border: Border.all(
                    color: otpState.errorMessage != null
                        ? colors.error
                        : otpState.isCodeComplete
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.outlineStrong,
                  ),
                ),
                child: TextField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.center,
                  onChanged: otpController.setCode,
                  style: typography.dataMedium.copyWith(
                    fontSize: 24,
                    letterSpacing: 8,
                    color: colors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '••••••',
                  ),
                ),
              ),
              if (otpState.errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  otpState.errorMessage!,
                  style: typography.caption.copyWith(color: colors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: otpState.isVerifying
                    ? ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authLoginWaitingHeading,
                        ),
                      )
                    : ref.watch(
                        rcTextProvider(RemoteConfigKeys.authOtpVerifyButton),
                      ),
                onPressed: otpState.isCodeComplete && !otpState.isVerifying
                    ? _verify
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: otpState.canResend
                    ? TextButton(
                        onPressed: _resend,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.authOtpResendButton,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      )
                    : Text(
                        ref
                            .watch(
                              rcTextProvider(
                                RemoteConfigKeys.authOtpResendCountdownTemplate,
                              ),
                            )
                            .replaceAll(
                              '{seconds}',
                              '${otpState.secondsRemaining}',
                            ),
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final otpController = ref.read(otpControllerProvider.notifier);
    final authRepository = ref.read(authRepositoryProvider);

    final success = await otpController.verify((code) async {
      switch (widget.purpose) {
        case OtpPurpose.login:
          await authRepository.verifyLoginOtp(uid: widget.uid!, code: code);
        case OtpPurpose.activation:
          await authRepository.verifyEmailSetupOtp(
            uid: widget.uid!,
            code: code,
          );
        case OtpPurpose.emailChange:
          await authRepository.verifyEmailChangeOtp(code);
      }
    });
    if (!success || !mounted) return;

    if (widget.purpose == OtpPurpose.emailChange) {
      ref.read(panelStackControllerProvider.notifier).pop();
      await widget.onVerified?.call();
      return;
    }

    // login/activation — signInWithCustomToken zaten çalıştı; appAccess
    // custom claim'e değil tek seferlik email okumasına dayandığı için
    // (bkz. currentUserEmailProvider) elle tazelenmesi gerekiyor.
    ref.invalidate(appAccessProvider);
  }

  Future<void> _resend() async {
    final otpController = ref.read(otpControllerProvider.notifier);
    final authRepository = ref.read(authRepositoryProvider);

    await otpController.resend(() async {
      switch (widget.purpose) {
        case OtpPurpose.login:
          await authRepository.startLogin(
            identifierType: 'email',
            value: widget.email,
          );
        case OtpPurpose.activation:
          await authRepository.sendEmailSetupOtp(
            uid: widget.uid!,
            email: widget.email,
          );
        case OtpPurpose.emailChange:
          await authRepository.sendEmailChangeOtp(widget.email);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
