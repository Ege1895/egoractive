import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../badges/controller/badges_controller.dart';
import '../../../badges/ui/panels/badges_panel.dart';
import '../../../feedback/ui/panels/feedback_panel.dart';
import '../../../gyms/ui/panels/gym_rules_view_panel.dart';
import '../../../members/ui/panels/member_self_info_panel.dart';
import '../../controller/auth_controller.dart';
import '../../controller/member_profile_controller.dart';
import 'delete_account_confirm_panel.dart';
import 'language_select_panel.dart';

/// Üye 8 · Profilim (Profil sekmesi kökü).
class ProfilePanel extends ConsumerWidget {
  const ProfilePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final controller = ref.read(authControllerProvider.notifier);
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    final profile = ref.watch(memberProfileControllerProvider);
    final profileController = ref.read(
      memberProfileControllerProvider.notifier,
    );
    // Firebase.initializeApp hiç çağrılmamış bir widget test ortamında
    // Remote Config okuması fırlatabilir (bkz. aynı desen member_home_panel.dart'ta).
    int reminderMinutesBefore;
    try {
      reminderMinutesBefore = ref
          .watch(remoteConfigServiceProvider)
          .sessionReminderMinutesBefore;
    } catch (_) {
      reminderMinutesBefore = 120;
    }
    final earnedBadgeCount = ref
        .watch(badgesControllerProvider)
        .where((b) => b.earned)
        .length;

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
              ref.watch(rcTextProvider(RemoteConfigKeys.authProfileTitle)),
              style: typography.headingLarge.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.lg),
            InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              onTap: () => panelStack.push(const MemberSelfInfoPanel()),
              child: Container(
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
                        _InitialsAvatar(
                          initials: _initialsOf(profile.name),
                          size: 64,
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
                                ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .authProfileMemberCaption,
                                      ),
                                    )
                                    .replaceAll('{phone}', profile.phoneE164),
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: colors.onSurfaceMuted,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
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
                      rcTextProvider(RemoteConfigKeys.authBadgesNavLabel),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$earnedBadgeCount',
                          style: typography.headingSmall.copyWith(
                            color: colors.onPrimaryContainer,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.chevron_right,
                          color: colors.onSurfaceMuted,
                          size: 18,
                        ),
                      ],
                    ),
                    onTap: () => panelStack.push(const BadgesPanel()),
                  ),
                  _NavRow(
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.authGiveFeedbackNavLabel),
                    ),
                    onTap: () => panelStack.push(const FeedbackPanel()),
                  ),
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
                    onTap: () => panelStack.push(const LanguageSelectPanel()),
                  ),
                  Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .authSessionRemindersToggleTitle,
                                  ),
                                ),
                                style: typography.bodyLarge.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .authProfileSessionReminderDescription,
                                      ),
                                    )
                                    .replaceAll(
                                      '{minutes}',
                                      '$reminderMinutesBefore',
                                    ),
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: profileController.toggleSessionReminder,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 52,
                            height: 32,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: profile.sessionReminderEnabled
                                  ? colors.primary
                                  : colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            alignment: profile.sessionReminderEnabled
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: colors.onSurface,
                                shape: BoxShape.circle,
                              ),
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
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.commonCikisYap),
                    ),
                    // Girişe dönüş burada elle yapılmıyor — `main.dart`'taki
                    // merkezi `appAccessProvider` dinleyicisi, signOut()
                    // tamamlanıp auth state null olduğunda zaten
                    // `PhoneLoginPanel`'e geçiyor. İkisi birden yapılırsa
                    // (aynı ekran için iki ayrı `replaceRoot` çağrısı yarışa
                    // girip) telefon input'unun bazen tıklanamaz kalmasına
                    // yol açan bir gesture/build yarışı oluşuyordu.
                    onTap: controller.logout,
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

/// Üyenin isim baş harfleri "Özlem Erbil" → "ÖE" — birden fazla kelimeden
/// oluşan isim/soyisimlerde ilk ve son kelimenin baş harfi alınır (bu
/// projede admin/antrenör özetlerinde de aynı kural kullanılıyor).
String _initialsOf(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: context.appTypography.headingMedium.copyWith(
          color: colors.onPrimary,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.label,
    this.trailing,
    this.onTap,
    this.labelColor,
    this.isLast = false,
  });

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
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceMuted,
                  size: 18,
                ),
          ],
        ),
      ),
    );
  }
}
