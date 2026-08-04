// Geçici geliştirici menüsü — gerçek auth/rol akışı tamamlanana kadar
// bileşen kütüphanesi ve rol shell'lerini elle test etmek için.
// F1-11 (gerçek custom-claim yönlendirmesi) tamamlanınca kaldırılır.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/component_showcase_panel.dart';
import '../../../modules/auth/ui/panels/delete_account_confirm_panel.dart';
import '../../../shared/widgets/app_button.dart';
import '../base_panel.dart';
import '../panel_stack_controller.dart';
import '../shell/role_picker_panel.dart';

class DevMenuPanel extends BasePanel {
  const DevMenuPanel({super.key});

  @override
  ConsumerState<DevMenuPanel> createState() => _DevMenuPanelState();
}

class _DevMenuPanelState extends BasePanelState<DevMenuPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final controller = ref.read(panelStackControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Geliştirici menüsü',
                style: typography.headingLarge.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Gerçek auth/rol akışı tamamlanana kadar geçici test kısayolları.',
                style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Bileşenleri gör',
                onPressed: () => controller.push(const ComponentShowcasePanel()),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Rolleri gör',
                variant: AppButtonVariant.secondary,
                onPressed: () => controller.push(const RolePickerPanel()),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Hesap silme onayı',
                variant: AppButtonVariant.secondary,
                onPressed: () => controller.push(const DeleteAccountConfirmPanel()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
