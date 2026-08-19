import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/sessions_controller.dart';
import '../../domain/session.dart';

/// Üye 1 · "Gelecek misin?" onay ekranı.
class AttendanceConfirmPanel extends BasePanel {
  const AttendanceConfirmPanel({super.key});

  @override
  ConsumerState<AttendanceConfirmPanel> createState() =>
      _AttendanceConfirmPanelState();
}

class _AttendanceConfirmPanelState
    extends BasePanelState<AttendanceConfirmPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(sessionsControllerProvider);
    final controller = ref.read(sessionsControllerProvider.notifier);
    final session = state.nextSession;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  AppBackButton(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Ders onayı',
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Yarın ${_hourFromTitle(session.title)}'daki dersine gelecek misin?",
                            style: typography.headingMedium.copyWith(
                              color: colors.onSurface,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            session.meta.isEmpty
                                ? 'Cevabını dersten 2 saat öncesine kadar değiştirebilirsin.'
                                : '${session.meta} seni bekliyor. Cevabını dersten 2 saat öncesine kadar değiştirebilirsin.',
                            style: typography.bodyMedium.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInner,
                              ),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      session.day,
                                      style: typography.dataMedium.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 24,
                                      ),
                                    ),
                                    Text(
                                      session.month,
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 1,
                                  height: 38,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  color: colors.outlineStrong,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        session.title,
                                        style: typography.headingSmall.copyWith(
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      Text(
                                        '${session.meta} · Kalan dersinden 1 düşer',
                                        style: typography.bodyMedium.copyWith(
                                          color: colors.onSurfaceVariant,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
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
                    if (!state.canConfirmAttendance) ...[
                      Text(
                        'Bu ders için geleceğini/gelmeyeceğini bildirme yetkin yok. Antrenörünle iletişime geç.',
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    ] else if (state.attendanceAnswer ==
                        AttendanceAnswer.pending) ...[
                      AppButton(
                        label: 'Gelicem',
                        onPressed: () => controller.confirmAttendance(true),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Gelmeyeceğim',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => controller.confirmAttendance(false),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color:
                              state.attendanceAnswer == AttendanceAnswer.coming
                              ? colors.successContainer
                              : colors.warningContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          border: Border.all(
                            color:
                                (state.attendanceAnswer ==
                                            AttendanceAnswer.coming
                                        ? colors.success
                                        : colors.warning)
                                    .withValues(alpha: 0.32),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color:
                                    state.attendanceAnswer ==
                                        AttendanceAnswer.coming
                                    ? colors.success
                                    : colors.warning,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                state.attendanceAnswer ==
                                        AttendanceAnswer.coming
                                    ? '✓'
                                    : '–',
                                style: typography.headingSmall.copyWith(
                                  color: colors.background,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.attendanceAnswer ==
                                            AttendanceAnswer.coming
                                        ? 'Geleceğini bildirdin'
                                        : 'Gelmeyeceğini bildirdin',
                                    style: typography.headingSmall.copyWith(
                                      color:
                                          state.attendanceAnswer ==
                                              AttendanceAnswer.coming
                                          ? colors.onSuccessContainer
                                          : colors.onWarningContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    state.attendanceAnswer ==
                                            AttendanceAnswer.coming
                                        ? (session.meta.isEmpty
                                              ? "Programda yerin ayrıldı. Dersten 2 saat öncesine kadar değiştirebilirsin."
                                              : "${session.meta}'ın programında yerin ayrıldı. Dersten 2 saat öncesine kadar değiştirebilirsin.")
                                        : "Ders kalan dersinden düşmedi, antrenörüne iletildi. Dersten 2 saat öncesine kadar değiştirebilirsin.",
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
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Cevabımı değiştir',
                        variant: AppButtonVariant.secondary,
                        onPressed: controller.resetAttendance,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _hourFromTitle(String title) {
    final match = RegExp(r'(\d{2}:\d{2})').firstMatch(title);
    return match?.group(1) ?? title;
  }
}
