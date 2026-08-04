// Geçici demo — F1-11'deki gerçek custom-claim bazlı rol yönlendirmesi
// gelene kadar 3 rol shell'ini manuel test etmek için. O görev tamamlanınca
// bu dosya silinir, yerini gerçek auth-sonrası yönlendirme alır.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../base_panel.dart';
import '../panel_stack_controller.dart';
import 'admin_shell_panel.dart';
import 'member_shell_panel.dart';
import 'trainer_shell_panel.dart';

class RolePickerPanel extends BasePanel {
  const RolePickerPanel({super.key});

  @override
  ConsumerState<RolePickerPanel> createState() => _RolePickerPanelState();
}

class _RolePickerPanelState extends BasePanelState<RolePickerPanel> {
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
                'Rol seç (demo)',
                style: typography.headingLarge.copyWith(color: colors.onSurface),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(label: 'Üye', onPressed: () => controller.push(const MemberShellPanel())),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Antrenör', onPressed: () => controller.push(const TrainerShellPanel())),
              const SizedBox(height: AppSpacing.sm),
              AppButton(label: 'Admin', onPressed: () => controller.push(const AdminShellPanel())),
            ],
          ),
        ),
      ),
    );
  }
}
