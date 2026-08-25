import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/domain/membership_installment.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../../../shared/utils/tr_date_formatter.dart';
import '../../../auth/controller/member_profile_controller.dart';
import '../../../gyms/controller/gym_profile_controller.dart';
import '../../../members/ui/panels/member_self_info_panel.dart';
import '../../../packages/controller/package_controller.dart';
import '../../controller/sessions_controller.dart';
import '../../domain/session.dart';
import 'attendance_confirm_panel.dart';

/// Üye · Ana Sayfa (Ana Sayfa sekmesi kökü).
class MemberHomePanel extends ConsumerWidget {
  const MemberHomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(sessionsControllerProvider);
    final sessionsController = ref.read(sessionsControllerProvider.notifier);
    final profile = ref.watch(memberProfileControllerProvider);
    final gymProfile = ref.watch(gymProfileControllerProvider);
    final pkg = ref.watch(packageControllerProvider);
    // Firebase.initializeApp hiç çağrılmamış bir widget test ortamında
    // Remote Config okuması fırlatabilir — bu durumda mock/sabit eşikle
    // devam edilir (bkz. create_group_session_controller.dart'taki aynı desen).
    int dueSoonDays;
    try {
      dueSoonDays = ref
          .watch(remoteConfigServiceProvider)
          .installmentDueSoonDays;
    } catch (_) {
      dueSoonDays = 3;
    }
    final firstName = profile.name.trim().isEmpty
        ? ''
        : profile.name.trim().split(RegExp(r'\s+')).first;
    final initials = profile.name.trim().isEmpty
        ? '?'
        : profile.name
              .trim()
              .split(RegExp(r'\s+'))
              .where((p) => p.isNotEmpty)
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase();

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
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  onTap: () => ref
                      .read(panelStackControllerProvider.notifier)
                      .push(const MemberSelfInfoPanel()),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: typography.headingSmall.copyWith(
                            color: colors.onPrimaryContainer,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gymProfile.name.isEmpty ? '—' : gymProfile.name,
                              overflow: TextOverflow.ellipsis,
                              style: typography.caption.copyWith(
                                color: colors.onSurfaceMuted,
                              ),
                            ),
                            Text(
                              ref
                                  .watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .sessionsMemberHomeGreeting,
                                    ),
                                  )
                                  .replaceAll(
                                    '{name}',
                                    firstName.isEmpty ? '' : ' $firstName',
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: typography.headingMedium.copyWith(
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outlineStrong),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
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
                  ProgressRing(
                    size: 88,
                    progress: pkg.progressRatio,
                    child: Text(
                      '${pkg.remainingSessions}',
                      style: typography.dataLarge.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .sessionsMemberHomeRemainingSessionsLabel,
                                ),
                              )
                              .replaceAll(
                                '{count}',
                                '${pkg.remainingSessions}',
                              ),
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .sessionsMemberHomePackageValidUntil,
                                ),
                              )
                              .replaceAll('{name}', pkg.name)
                              .replaceAll('{date}', pkg.endDate),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.sessionsMemberHomeNextSessionSection,
                ),
              ),
              style: typography.caption.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              onTap: !state.canConfirmAttendance
                  ? null
                  : () => ref
                        .read(panelStackControllerProvider.notifier)
                        .push(const AttendanceConfirmPanel()),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                state.nextSession.day,
                                style: typography.dataMedium.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                state.nextSession.month,
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.nextSession.title,
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                              Text(
                                state.nextSession.meta,
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
                    if (state.canConfirmAttendance) ...[
                      const SizedBox(height: AppSpacing.md),
                      if (state.attendanceErrorMessage != null) ...[
                        Text(
                          state.attendanceErrorMessage!,
                          style: typography.bodyMedium.copyWith(
                            color: colors.error,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      if (state.attendanceAnswer == AttendanceAnswer.pending)
                        Row(
                          children: [
                            Expanded(
                              child: _QuickActionButton(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonGelicem,
                                  ),
                                ),
                                filled: true,
                                onTap: () =>
                                    sessionsController.confirmAttendance(true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _QuickActionButton(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonGelmeyecegim,
                                  ),
                                ),
                                filled: false,
                                onTap: () =>
                                    sessionsController.confirmAttendance(false),
                              ),
                            ),
                          ],
                        )
                      else
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            state.attendanceAnswer == AttendanceAnswer.coming
                                ? ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .sessionsConfirmAttendingAnswerText,
                                    ),
                                  )
                                : ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .sessionsConfirmNotAttendingAnswerText,
                                    ),
                                  ),
                            style: typography.bodyMedium.copyWith(
                              color:
                                  state.attendanceAnswer ==
                                      AttendanceAnswer.coming
                                  ? colors.success
                                  : colors.onWarningContainer,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            if (pkg.installments.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                ref.watch(
                  rcTextProvider(
                    RemoteConfigKeys.sessionsMemberHomeInstallmentsSection,
                  ),
                ),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < pkg.installments.length; i++)
                      _MemberInstallmentRow(
                        installment: pkg.installments[i],
                        showDivider: i < pkg.installments.length - 1,
                        isDueSoon:
                            !pkg.installments[i].paid &&
                            pkg.installments[i].dueDate
                                    .difference(DateTime.now())
                                    .inDays <=
                                dueSoonDays,
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.sessionsMemberHomeThisWeekSection,
                ),
              ),
              style: typography.caption.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 118,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final day in state.week)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: FractionallySizedBox(
                                alignment: Alignment.bottomCenter,
                                heightFactor: day.intensity.clamp(0.08, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: day.isRestDay
                                        ? colors.surfaceRaised
                                        : colors.primary.withValues(
                                            alpha: 0.85,
                                          ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              day.label,
                              textAlign: TextAlign.center,
                              style: typography.caption.copyWith(
                                color: colors.onSurfaceMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: filled ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 15,
              color: filled ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberInstallmentRow extends ConsumerWidget {
  const _MemberInstallmentRow({
    required this.installment,
    required this.showDivider,
    required this.isDueSoon,
  });

  final MembershipInstallment installment;
  final bool showDivider;

  /// Son ödeme tarihine RC eşiği kadar (veya daha az) gün kaldıysa ya da
  /// geçmişse `true` — sadece ödenmemiş taksitler için anlamlı.
  final bool isDueSoon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (badgeLabel, badgeBg, badgeFg) = installment.paid
        ? (
            ref.watch(rcTextProvider(RemoteConfigKeys.membersDetailPaidLabel)),
            colors.successContainer,
            colors.onSuccessContainer,
          )
        : isDueSoon
        ? (
            ref.watch(
              rcTextProvider(
                RemoteConfigKeys.sessionsMemberHomeInstallmentDueSoonLabel,
              ),
            ),
            colors.errorContainer,
            colors.onErrorContainer,
          )
        : (
            ref.watch(
              rcTextProvider(
                RemoteConfigKeys.sessionsMemberHomeInstallmentUnpaidLabel,
              ),
            ),
            colors.warningContainer,
            colors.onWarningContainer,
          );
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              ref
                  .watch(
                    rcTextProvider(
                      RemoteConfigKeys.sessionsMemberHomeInstallmentIndexLabel,
                    ),
                  )
                  .replaceAll('{index}', '${installment.index}'),
              style: typography.bodyLarge.copyWith(
                color: colors.onSurface,
                fontSize: 15,
              ),
            ),
          ),
          if (!installment.paid) ...[
            Text(
              ref
                  .watch(
                    rcTextProvider(
                      RemoteConfigKeys
                          .sessionsMemberHomeInstallmentDueDateLabel,
                    ),
                  )
                  .replaceAll('{date}', formatTrDate(installment.dueDate)),
              style: typography.caption.copyWith(color: colors.onSurfaceMuted),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
            child: Text(
              badgeLabel,
              style: typography.caption.copyWith(color: badgeFg, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
