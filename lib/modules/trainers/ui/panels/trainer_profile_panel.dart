import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../auth/ui/panels/delete_account_confirm_panel.dart';
import '../../../auth/ui/panels/language_select_panel.dart';
import '../../../gyms/ui/panels/gym_rules_view_panel.dart';
import '../../controller/trainer_profile_controller.dart';

/// Antrenör · Profil (Profil sekmesi kökü) — üye Profilim'in sade antrenör
/// karşılığı, rozet/geri bildirim gibi üyeye özgü bölümler içermez.
class TrainerProfilePanel extends ConsumerWidget {
  const TrainerProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    final profile = ref.watch(trainerProfileControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.lg,
            AppSpacing.screenEdge,
            AppSpacing.lg,
          ),
          children: [
            Text(
              ref.watch(rcTextProvider(RemoteConfigKeys.commonProfilTab)),
              style: typography.headingLarge.copyWith(color: colors.onSurface),
            ),
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
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      profile.initials,
                      style: typography.headingMedium.copyWith(
                        color: colors.onPrimaryContainer,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name.isEmpty ? '—' : profile.name,
                          style: typography.headingMedium.copyWith(
                            color: colors.onSurface,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          profile.specialty.isEmpty
                              ? ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersTrainerFieldLabel,
                                  ),
                                )
                              : ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .trainersProfileSpecialtyRole,
                                      ),
                                    )
                                    .replaceAll(
                                      '{specialty}',
                                      profile.specialty,
                                    ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
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
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.commonStudyoKurallariNav),
                    ),
                    onTap: () => panelStack.push(const GymRulesViewPanel()),
                  ),
                  _NavRow(
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.commonLanguageNavLabel),
                    ),
                    isLast: true,
                    onTap: () => panelStack.push(const LanguageSelectPanel()),
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
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.commonCikisYap),
                    ),
                    // Girişe dönüş burada elle yapılmıyor — `main.dart`'taki
                    // merkezi `appAccessProvider` dinleyicisi auth state null
                    // olunca zaten `PhoneLoginPanel`'e geçiyor (iki ayrı
                    // `replaceRoot` çağrısının yarışa girip telefon input'unun
                    // bazen tıklanamaz kalmasını önlemek için).
                    onTap: () =>
                        ref.read(authControllerProvider.notifier).logout(),
                  ),
                  _NavRow(
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.commonHesabimiSil),
                    ),
                    labelColor: colors.error,
                    isLast: true,
                    onTap: () =>
                        panelStack.push(const DeleteAccountConfirmPanel()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.trainersProfileFooterText),
                ),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    this.onTap,
    this.labelColor,
    this.isLast = false,
  });

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
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: colors.outline)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: typography.bodyLarge.copyWith(
                color: labelColor ?? colors.onSurface,
                fontSize: 15,
              ),
            ),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
