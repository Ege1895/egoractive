import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/auth_controller.dart';
import '../../domain/auth_login_exception.dart';
import '../../domain/otp_purpose.dart';
import 'email_login_panel.dart';
import 'email_setup_panel.dart';
import 'otp_verification_panel.dart';

/// Ortak 2 · Telefon Numarası Girişi.
///
/// [prefillPhoneDigits] ve [successBanner], F2-9'daki "yeni salon oluştur"
/// akışının son adımında kullanılır: salon kaydı tamamlanınca kullanıcı bu
/// ekrana, az önce girdiği numara önceden dolu ve bir başarı mesajıyla
/// yönlendirilir.
///
/// Egoractive Authentication Sistemi §2/§8 — bu panelde (ve email eşleniği
/// [EmailLoginPanel]'de) geri butonu HİÇBİR ZAMAN gösterilmez; sadece OTP
/// ekranının kendi geri butonu var.
class PhoneLoginPanel extends BasePanel {
  const PhoneLoginPanel({
    super.key,
    this.prefillPhoneDigits,
    this.successBanner,
    this.errorBanner,
  });

  final String? prefillPhoneDigits;
  final String? successBanner;

  /// Salon Abonelik ve Erişim Akışı — zaten oturum açmış bir antrenör/üyenin
  /// salonu aboneliği inaktif olunca [main.dart]'ın erişim kapısı tarafından
  /// otomatik çıkış yaptırılıp bu ekrana yönlendirildiğinde gösterilir
  /// (`successBanner`'ın kırmızı/error eşdeğeri).
  final String? errorBanner;

  @override
  ConsumerState<PhoneLoginPanel> createState() => _PhoneLoginPanelState();
}

class _PhoneLoginPanelState extends BasePanelState<PhoneLoginPanel> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    final prefill = widget.prefillPhoneDigits;
    if (prefill != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(authControllerProvider.notifier).setPhoneDigits(prefill);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    final formatted = formatTrPhoneDigits(authState.phoneDigits);
    if (_phoneController.text != formatted) {
      _phoneController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.xxl,
            AppSpacing.screenEdge,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.successBanner != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.successBanner!,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onPrimaryContainer,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (widget.errorBanner != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.errorBanner!,
                    style: typography.bodyMedium.copyWith(
                      color: colors.error,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                ref.watch(rcTextProvider(RemoteConfigKeys.authPhoneLoginTitle)),
                style: typography.headingLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authPhoneLoginSubtitle),
                ),
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authPhoneNumberLabel),
                ),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  border: Border.all(
                    color:
                        authState.loginErrorReason ==
                            AuthLoginErrorReason.notFound
                        ? colors.error
                        : authState.isPhoneComplete
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.outlineStrong,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '+90',
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(
                      width: 1,
                      height: 26,
                      color: colors.outlineStrong,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [TrPhoneNumberInputFormatter()],
                        onChanged: authController.setPhoneDigits,
                        style: typography.dataMedium.copyWith(
                          fontSize: 20,
                          color: colors.onSurface,
                        ),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '5XX XXX XX XX',
                          hintStyle: typography.dataMedium.copyWith(
                            fontSize: 20,
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                authState.loginErrorMessage ??
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.authPhoneLoginHint),
                    ),
                style: typography.caption.copyWith(
                  color: authState.loginErrorMessage != null
                      ? colors.error
                      : colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: authState.isRequestingLogin
                    ? ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authLoginWaitingHeading,
                        ),
                      )
                    : ref.watch(
                        rcTextProvider(RemoteConfigKeys.authLoginButton),
                      ),
                onPressed:
                    authState.isPhoneComplete && !authState.isRequestingLogin
                    ? () => _submit(authController)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => ref
                      .read(panelStackControllerProvider.notifier)
                      .replaceTop(const EmailLoginPanel()),
                  child: Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.authSwitchToEmailLink),
                    ),
                    style: typography.bodyMedium.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AuthController authController) async {
    final result = await authController.startLogin(identifierType: 'phone');
    if (result == null || !mounted) return;
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    if (result.needsEmailSetup) {
      panelStack.push(EmailSetupPanel(uid: result.uid));
    } else {
      panelStack.push(
        OtpVerificationPanel(
          purpose: OtpPurpose.login,
          uid: result.uid,
          email: result.email!,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
