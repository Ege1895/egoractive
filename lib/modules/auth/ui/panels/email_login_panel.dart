import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/auth_controller.dart';
import '../../domain/auth_login_exception.dart';
import '../../domain/otp_purpose.dart';
import 'otp_verification_panel.dart';
import 'phone_login_panel.dart';

/// Ortak 2 · Email ile Giriş — [PhoneLoginPanel]'in eşleniği. Egoractive
/// Authentication Sistemi §2 — bu ikisi birbirinin alternatifi, geri butonu
/// hiçbirinde yok, aralarında geçiş `replaceTop` ile (stack büyümeden).
class EmailLoginPanel extends BasePanel {
  const EmailLoginPanel({super.key});

  @override
  ConsumerState<EmailLoginPanel> createState() => _EmailLoginPanelState();
}

class _EmailLoginPanelState extends BasePanelState<EmailLoginPanel> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: ref.read(authControllerProvider).emailInput,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

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
              Text(
                ref.watch(rcTextProvider(RemoteConfigKeys.authEmailLoginTitle)),
                style: typography.headingLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 30,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authEmailLoginSubtitle),
                ),
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authEmailAddressLabel),
                ),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  border: Border.all(
                    color:
                        authState.loginErrorReason ==
                            AuthLoginErrorReason.notFound
                        ? colors.error
                        : authState.isEmailComplete
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.outlineStrong,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onChanged: authController.setEmailInput,
                  style: typography.dataMedium.copyWith(
                    fontSize: 18,
                    color: colors.onSurface,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: 'ornek@email.com',
                    hintStyle: typography.dataMedium.copyWith(
                      fontSize: 18,
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
              if (authState.loginErrorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  authState.loginErrorMessage!,
                  style: typography.caption.copyWith(color: colors.error),
                ),
              ],
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
                    authState.isEmailComplete && !authState.isRequestingLogin
                    ? () => _submit(authController)
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => ref
                      .read(panelStackControllerProvider.notifier)
                      .replaceTop(const PhoneLoginPanel()),
                  child: Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.authSwitchToPhoneLink),
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
    final result = await authController.startLogin(identifierType: 'email');
    if (result == null || !mounted) return;
    ref
        .read(panelStackControllerProvider.notifier)
        .push(
          OtpVerificationPanel(
            purpose: OtpPurpose.login,
            uid: result.uid,
            email: result.email!,
          ),
        );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
