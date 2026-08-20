import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import 'onboarding_trainer_path_panel.dart';
import 'phone_login_panel.dart';

enum _OnboardingRole { trainer, member }

/// Ortak 1 · Rol Seçimi — uygulamayı ilk kez açan, henüz giriş yapmamış
/// kullanıcıya gösterilen kök ekran. `SplashPanel`'in ardından gelir.
///
/// Akış: "Üyeyim" → [PhoneLoginPanel] · "Antrenörüm" → [OnboardingTrainerPathPanel]
/// (oradan da ya `PhoneLoginPanel`'e ya da salon oluşturmaya gider).
class OnboardingRolePanel extends BasePanel {
  const OnboardingRolePanel({super.key});

  @override
  ConsumerState<OnboardingRolePanel> createState() =>
      _OnboardingRolePanelState();
}

class _OnboardingRolePanelState extends BasePanelState<OnboardingRolePanel> {
  _OnboardingRole? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.xxl,
            AppSpacing.screenEdge,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Image.asset('assets/images/egora-logo.png'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.authOnboardingRoleBrandLabel,
                      ),
                    ),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authOnboardingRoleTitle),
                ),
                style: typography.headingLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.authOnboardingRoleSubtitle),
                ),
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _RoleCard(
                icon: Icons.timer_rounded,
                title: ref.watch(
                  rcTextProvider(
                    RemoteConfigKeys.authOnboardingRoleTrainerTitle,
                  ),
                ),
                note: ref.watch(
                  rcTextProvider(
                    RemoteConfigKeys.authOnboardingRoleTrainerNote,
                  ),
                ),
                iconRadius: 16,
                selected: _selected == _OnboardingRole.trainer,
                onTap: () =>
                    setState(() => _selected = _OnboardingRole.trainer),
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleCard(
                icon: Icons.favorite_rounded,
                title: ref.watch(
                  rcTextProvider(
                    RemoteConfigKeys.authOnboardingRoleMemberTitle,
                  ),
                ),
                note: ref.watch(
                  rcTextProvider(RemoteConfigKeys.authOnboardingRoleMemberNote),
                ),
                iconRadius: AppSpacing.radiusPill,
                selected: _selected == _OnboardingRole.member,
                onTap: () => setState(() => _selected = _OnboardingRole.member),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _hint(ref),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              AppButton(
                label: _selected == _OnboardingRole.trainer
                    ? ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authOnboardingRoleContinueButton,
                        ),
                      )
                    : ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.authOnboardingRoleGoToLoginButton,
                        ),
                      ),
                onPressed: _selected == null ? null : _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _hint(WidgetRef ref) => switch (_selected) {
    _OnboardingRole.trainer => ref.watch(
      rcTextProvider(RemoteConfigKeys.authOnboardingRoleHintTrainer),
    ),
    _OnboardingRole.member || null => ref.watch(
      rcTextProvider(RemoteConfigKeys.authOnboardingRoleHintMember),
    ),
  };

  void _onContinue() {
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    if (_selected == _OnboardingRole.member) {
      panelStack.push(const PhoneLoginPanel());
    } else {
      panelStack.push(const OnboardingTrainerPathPanel());
    }
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.note,
    required this.iconRadius,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String note;
  final double iconRadius;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: selected ? colors.primary : colors.outline,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primaryContainer
                      : colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(iconRadius),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? colors.primary : colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      note,
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _RadioDot(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primary : colors.outlineStrong,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary,
              ),
            )
          : null,
    );
  }
}
