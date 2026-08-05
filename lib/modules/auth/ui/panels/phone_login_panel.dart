import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/auth_controller.dart';
import 'login_waiting_panel.dart';

/// Ortak 2 · Telefon Numarası Girişi.
class PhoneLoginPanel extends BasePanel {
  const PhoneLoginPanel({super.key});

  @override
  ConsumerState<PhoneLoginPanel> createState() => _PhoneLoginPanelState();
}

class _PhoneLoginPanelState extends BasePanelState<PhoneLoginPanel> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
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
              Text(
                'Telefonunla giriş yap',
                style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 30),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Stüdyona kayıtlı numaranı gir; şifre yok, tek dokunuşla girersin.',
                style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Telefon numarası', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  border: Border.all(
                    color: authState.isPhoneComplete
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.outlineStrong,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '+90',
                      style: typography.headingSmall.copyWith(color: colors.onSurfaceMuted, fontSize: 18),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Container(width: 1, height: 26, color: colors.outlineStrong),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [_PhoneNumberInputFormatter()],
                        onChanged: authController.setPhoneDigits,
                        style: typography.dataMedium.copyWith(fontSize: 20, color: colors.onSurface),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintText: '5XX XXX XX XX',
                          hintStyle: typography.dataMedium.copyWith(fontSize: 20, color: colors.onSurfaceMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Numaran kayıtlı değilse stüdyo yönetimi seni eklemeli.',
                style: typography.caption.copyWith(color: colors.onSurfaceMuted),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: 'Giriş yap',
                onPressed: authState.isPhoneComplete
                    ? () {
                        authController.requestLogin();
                        ref.read(panelStackControllerProvider.notifier).push(const LoginWaitingPanel());
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}

/// Kullanıcı yazdıkça haneleri "5XX XXX XX XX" olarak gruplar.
class _PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final formatted = formatTrPhoneDigits(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
