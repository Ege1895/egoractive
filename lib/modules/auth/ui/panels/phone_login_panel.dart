import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/dev/dev_menu_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/auth_controller.dart';
import 'login_waiting_panel.dart';

const _keypadRows = [
  ['1', '2', '3'],
  ['4', '5', '6'],
  ['7', '8', '9'],
  ['', '0', '⌫'],
];

/// Ortak 2 · Telefon Numarası Girişi.
class PhoneLoginPanel extends BasePanel {
  const PhoneLoginPanel({super.key});

  @override
  ConsumerState<PhoneLoginPanel> createState() => _PhoneLoginPanelState();
}

class _PhoneLoginPanelState extends BasePanelState<PhoneLoginPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final authState = ref.watch(authControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);
    final hasDigits = authState.phoneDigits.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.xxl,
                  AppSpacing.screenEdge,
                  AppSpacing.sm,
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
                          Text(
                            hasDigits ? formatTrPhoneDigits(authState.phoneDigits) : '5XX XXX XX XX',
                            style: typography.dataMedium.copyWith(
                              fontSize: 20,
                              color: hasDigits ? colors.onSurface : colors.onSurfaceMuted,
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
                              ref
                                  .read(panelStackControllerProvider.notifier)
                                  .push(const LoginWaitingPanel());
                            }
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Align(
                      alignment: Alignment.center,
                      child: AppButton(
                        label: 'Geliştirici menüsü',
                        variant: AppButtonVariant.text,
                        expand: false,
                        onPressed: () => ref
                            .read(panelStackControllerProvider.notifier)
                            .push(const DevMenuPanel()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _Keypad(onDigit: authController.appendDigit, onBackspace: authController.removeLastDigit),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.outline)),
      ),
      child: Column(
        children: [
          for (final row in _keypadRows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  for (final key in row)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: _KeypadButton(
                          key: key.isEmpty ? null : ValueKey('keypad-$key'),
                          label: key,
                          textStyle: typography.dataMedium.copyWith(
                            fontSize: 22,
                            color: key == '⌫' ? colors.onSurfaceMuted : colors.onSurface,
                          ),
                          bg: key.isEmpty || key == '⌫' ? Colors.transparent : colors.surfaceRaised,
                          onTap: key.isEmpty
                              ? null
                              : key == '⌫'
                                  ? onBackspace
                                  : () => onDigit(key),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.textStyle,
    required this.bg,
    required this.onTap,
    super.key,
  });

  final String label;
  final TextStyle textStyle;
  final Color bg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.primaryActionHeight),
          alignment: Alignment.center,
          child: Text(label, style: textStyle),
        ),
      ),
    );
  }
}
