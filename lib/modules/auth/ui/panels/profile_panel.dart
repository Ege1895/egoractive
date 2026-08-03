import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/avatar_palette.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/mock/member_mock_profile.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../badges/ui/panels/badges_panel.dart';
import '../../../feedback/ui/panels/feedback_panel.dart';
import '../../controller/auth_controller.dart';
import 'delete_account_confirm_panel.dart';
import 'phone_login_panel.dart';

/// Üye 8 · Profilim (Profil sekmesi kökü).
class ProfilePanel extends ConsumerWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    final avatarColor = AppAvatarPalette.colors[state.selectedAvatarIndex];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
          children: [
            Text('Profilim', style: typography.headingLarge.copyWith(color: colors.onSurface)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _AvatarCircle(color: avatarColor, size: 64, selected: true),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              MemberMockProfile.memberFullName,
                              style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 19),
                            ),
                            Text(
                              '+90 ${formatTrPhoneDigits(MemberMockProfile.memberPhoneDigits)} · Üye',
                              style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Avatarını seç', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (var i = 0; i < AppAvatarPalette.colors.length; i++)
                        GestureDetector(
                          onTap: () => controller.selectAvatar(i),
                          child: _AvatarCircle(
                            color: AppAvatarPalette.colors[i],
                            size: 52,
                            selected: i == state.selectedAvatarIndex,
                          ),
                        ),
                    ],
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
              child: Column(
                children: [
                  _NavRow(
                    label: 'Rozetlerim',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('4', style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15)),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
                      ],
                    ),
                    onTap: () => panelStack.push(const BadgesPanel()),
                  ),
                  _NavRow(
                    label: 'Geri bildirim ver',
                    onTap: () => panelStack.push(const FeedbackPanel()),
                  ),
                  const _NavRow(label: 'Stüdyo kuralları'),
                  Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ders hatırlatmaları', style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                              Text('Dersinden 2 saat önce bildirim', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.toggleSessionReminder,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 52,
                            height: 32,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: state.sessionReminderEnabled ? colors.primary : colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            alignment: state.sessionReminderEnabled ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(color: colors.onSurface, shape: BoxShape.circle),
                            ),
                          ),
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
              child: Column(
                children: [
                  _NavRow(
                    label: 'Çıkış yap',
                    onTap: () {
                      controller.logout();
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
              child: Text(
                'Egoractive · Egora Games · Sürüm 1.0',
                style: typography.caption.copyWith(color: colors.onSurfaceMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({required this.color, required this.size, required this.selected});

  final Color color;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(color.withValues(alpha: 0.26), colors.background),
        border: Border.all(color: selected ? colors.primary : colors.outline, width: 2),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: size * 0.16, height: size * 0.16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            SizedBox(width: size * 0.08),
            Container(width: size * 0.16, height: size * 0.16, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.label, this.trailing, this.onTap, this.labelColor, this.isLast = false});

  final String label;
  final Widget? trailing;
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
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: colors.outline)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: typography.bodyLarge.copyWith(color: labelColor ?? colors.onSurface, fontSize: 15)),
            trailing ?? Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
