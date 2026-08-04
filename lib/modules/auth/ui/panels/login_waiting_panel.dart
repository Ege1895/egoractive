import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../controller/auth_controller.dart';

/// Ortak 3 · Giriş Bekleniyor — kod/token bekleme durumu.
class LoginWaitingPanel extends BasePanel {
  const LoginWaitingPanel({super.key});

  @override
  ConsumerState<LoginWaitingPanel> createState() => _LoginWaitingPanelState();
}

class _LoginWaitingPanelState extends BasePanelState<LoginWaitingPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final phoneDigits = ref.watch(authControllerProvider).phoneDigits;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLoadingIndicator(size: 76),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Seni tanıyoruz…',
                      style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 22),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '+90 ${formatTrPhoneDigits(phoneDigits)} numarası stüdyoda aranıyor.',
                      style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.screenEdge,
              right: AppSpacing.screenEdge,
              bottom: 56,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  border: Border.all(color: colors.outline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 5),
                      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        '30 saniyeden uzun sürerse bağlantını kontrol edip tekrar dene.',
                        style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.screenEdge,
              right: AppSpacing.screenEdge,
              bottom: 0,
              child: AppButton(
                label: 'İptal',
                variant: AppButtonVariant.text,
                onPressed: () => ref.read(panelStackControllerProvider.notifier).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
