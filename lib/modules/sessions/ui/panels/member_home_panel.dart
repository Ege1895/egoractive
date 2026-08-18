import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/mock/member_mock_profile.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../controller/sessions_controller.dart';
import '../../domain/session.dart';
import '../../../packages/ui/panels/package_panel.dart';
import 'attendance_confirm_panel.dart';

/// Üye · Ana Sayfa (Ana Sayfa sekmesi kökü).
class MemberHomePanel extends ConsumerWidget {
  const MemberHomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(sessionsControllerProvider);
    final controller = ref.read(sessionsControllerProvider.notifier);

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
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'AY',
                    style: typography.headingSmall.copyWith(
                      color: colors.onPrimaryContainer,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MemberMockProfile.gymName,
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                      Text(
                        'Merhaba ${MemberMockProfile.memberFirstName}',
                        style: typography.headingMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.outlineStrong),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.warning,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.background,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    progress:
                        MemberMockProfile.remainingSessions /
                        MemberMockProfile.totalSessions,
                    child: Text(
                      '${MemberMockProfile.remainingSessions}',
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
                          'Kalan dersin: ${MemberMockProfile.remainingSessions}',
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${MemberMockProfile.packageName} paketi · ${MemberMockProfile.packageEnd}\'e kadar geçerli',
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
            if (state.paymentWarning != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.warningContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: colors.warning.withValues(alpha: 0.32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.warning,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '!',
                            style: typography.headingSmall.copyWith(
                              color: colors.warningContainer,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ödeme zamanı yaklaşıyor',
                                style: typography.headingSmall.copyWith(
                                  color: colors.onWarningContainer,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                '${state.paymentWarning!.amount} kalan ödemen ${state.paymentWarning!.dueDate}\'ta son buluyor. '
                                'Antrenörüne bugün iletebilirsin.',
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SecondaryActionButton(
                      label: 'Paketimi gör',
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(const PackagePanel()),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              'SIRADAKİ DERSİN',
              style: typography.caption.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              onTap: () => ref
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
                              label: 'Gelicem',
                              filled: true,
                              onTap: () => controller.confirmAttendance(true),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _QuickActionButton(
                              label: 'Gelmeyeceğim',
                              filled: false,
                              onTap: () => controller.confirmAttendance(false),
                            ),
                          ),
                        ],
                      )
                    else
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          state.attendanceAnswer == AttendanceAnswer.coming
                              ? 'Geleceğini bildirdin'
                              : 'Gelmeyeceğini bildirdin',
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
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'BU HAFTA',
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

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 44),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 15,
              color: colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
