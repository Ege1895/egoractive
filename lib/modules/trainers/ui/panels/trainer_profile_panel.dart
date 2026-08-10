import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/mock/trainer_mock_data.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../auth/ui/panels/delete_account_confirm_panel.dart';
import '../../../auth/ui/panels/phone_login_panel.dart';
import '../../../gyms/ui/panels/gym_rules_view_panel.dart';

/// Antrenör · Profil (Profil sekmesi kökü) — üye Profilim'in sade antrenör
/// karşılığı, rozet/geri bildirim gibi üyeye özgü bölümler içermez.
class TrainerProfilePanel extends ConsumerWidget {
  const TrainerProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final panelStack = ref.read(panelStackControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
          children: [
            Text('Profil', style: typography.headingLarge.copyWith(color: colors.onSurface)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      TrainerMockData.trainerInitials,
                      style: typography.headingMedium.copyWith(color: colors.onPrimaryContainer, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(TrainerMockData.trainerName, style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 19)),
                        Text(
                          '${TrainerMockData.specialty} · Antrenör',
                          style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(children: [
                _NavRow(
                  label: 'Stüdyo kuralları',
                  isLast: true,
                  onTap: () => panelStack.push(const GymRulesViewPanel()),
                ),
              ]),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                children: [
                  _NavRow(
                    label: 'Çıkış yap',
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout();
                      panelStack.replaceRoot(const PhoneLoginPanel());
                    },
                  ),
                  _NavRow(
                    label: 'Hesabımı sil',
                    labelColor: colors.error,
                    isLast: true,
                    onTap: () => panelStack.push(const DeleteAccountConfirmPanel()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text('Egoractive · Egora Games · Sürüm 1.0', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.label, this.onTap, this.labelColor, this.isLast = false});

  final String label;
  final VoidCallback? onTap;
  final Color? labelColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: colors.outline))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: typography.bodyLarge.copyWith(color: labelColor ?? colors.onSurface, fontSize: 15)),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
