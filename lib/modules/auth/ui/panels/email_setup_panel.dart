import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../domain/otp_exception.dart';
import '../../domain/otp_purpose.dart';
import '../../repository/auth_repository.dart';
import 'otp_verification_panel.dart';

/// Egoractive Authentication Sistemi §5/§6 — hem admin tarafından oluşturulup
/// email'i hiç girilmemiş bir member/trainer'ın ilk aktivasyonu, hem de
/// email'i boş mevcut bir hesabın app açılışında yakalanıp email
/// eklettirilmesi TEK bu paneli paylaşır — ikisi de sadece [uid] alır,
/// ikisinde de aynı `sendEmailSetupOtp`/`verifyEmailSetupOtp` çifti çalışır.
class EmailSetupPanel extends BasePanel {
  const EmailSetupPanel({super.key, required this.uid});

  final String uid;

  @override
  ConsumerState<EmailSetupPanel> createState() => _EmailSetupPanelState();
}

class _EmailSetupPanelState extends BasePanelState<EmailSetupPanel> {
  late final TextEditingController _emailController;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final canPop = ref.watch(panelStackControllerProvider).length > 1;

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
              if (canPop) ...[
                AppBackButton(
                  onTap: () =>
                      ref.read(panelStackControllerProvider.notifier).pop(),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                ref.watch(rcTextProvider(RemoteConfigKeys.authEmailSetupTitle)),
                style: typography.headingLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authEmailSetupSubtitle),
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
                    color: _errorMessage != null
                        ? colors.error
                        : colors.outlineStrong,
                  ),
                ),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (_errorMessage != null)
                      setState(() => _errorMessage = null);
                  },
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
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _errorMessage!,
                  style: typography.caption.copyWith(color: colors.error),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _isSending
                    ? ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authLoginWaitingHeading,
                        ),
                      )
                    : ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authEmailSetupSendButton,
                        ),
                      ),
                onPressed: _isSending ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _isEmailValid {
    final value = _emailController.text.trim();
    return value.contains('@') && value.length > 3;
  }

  Future<void> _submit() async {
    if (!_isEmailValid) {
      setState(() {
        _errorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.authEmailSetupInvalidEmailError),
        );
      });
      return;
    }
    final email = _emailController.text.trim();
    setState(() {
      _isSending = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .sendEmailSetupOtp(uid: widget.uid, email: email);
      if (!mounted) return;
      setState(() => _isSending = false);
      ref
          .read(panelStackControllerProvider.notifier)
          .push(
            OtpVerificationPanel(
              purpose: OtpPurpose.activation,
              uid: widget.uid,
              email: email,
            ),
          );
    } on OtpException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = e.reason == OtpErrorReason.emailTaken
            ? ref.read(
                rcTextProvider(RemoteConfigKeys.authEmailSetupEmailTakenError),
              )
            : ref.read(rcTextProvider(RemoteConfigKeys.authOtpGenericError));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _errorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.authOtpGenericError),
        );
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
