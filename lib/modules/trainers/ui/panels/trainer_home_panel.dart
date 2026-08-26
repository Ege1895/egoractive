import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../sessions/ui/panels/trainer_notifications_panel.dart';
import '../../controller/trainer_home_controller.dart';
import '../../controller/trainer_profile_controller.dart';
import '../../domain/pending_confirmation.dart';
import '../../domain/schedule_slot.dart';

const _weekdayNames = {
  1: 'Pazartesi',
  2: 'Salı',
  3: 'Çarşamba',
  4: 'Perşembe',
  5: 'Cuma',
  6: 'Cumartesi',
  7: 'Pazar',
};
const _monthNames = {
  1: 'Ocak',
  2: 'Şubat',
  3: 'Mart',
  4: 'Nisan',
  5: 'Mayıs',
  6: 'Haziran',
  7: 'Temmuz',
  8: 'Ağustos',
  9: 'Eylül',
  10: 'Ekim',
  11: 'Kasım',
  12: 'Aralık',
};

String _todayLabel() {
  final now = DateTime.now();
  return '${_weekdayNames[now.weekday]}, ${now.day} ${_monthNames[now.month]}';
}

/// Antrenör 1 · Ana Sayfa (Ana Sayfa sekmesi kökü) — bugünkü program +
/// bekleyen "tamamlandı mı?" onayları.
class TrainerHomePanel extends ConsumerWidget {
  const TrainerHomePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(trainerHomeControllerProvider);
    final controller = ref.read(trainerHomeControllerProvider.notifier);
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
                    profile.initials,
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
                        _todayLabel(),
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                      Text(
                        profile.name.trim().isEmpty
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.trainersHomeGreeting,
                                ),
                              )
                            : ref
                                  .watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .trainersHomeGreetingWithName,
                                    ),
                                  )
                                  .replaceAll(
                                    '{name}',
                                    profile.name.trim().split(' ').first,
                                  ),
                        style: typography.headingMedium.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () =>
                      panelStack.push(const TrainerNotificationsPanel()),
                  child: Container(
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
                        if (state.pendingConfirmations.isNotEmpty)
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
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersHomeTodaySessionsLabel,
                      ),
                    ),
                    value: '${state.todaySessionCount}',
                    valueColor: colors.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatTile(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersHomeCompletedLabel,
                      ),
                    ),
                    value: '${state.completedCount}',
                    valueColor: colors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatTile(
                    label: ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersHomeFreeSlotLabel,
                      ),
                    ),
                    value: '${state.freeSlotCount}',
                    valueColor: colors.onSurface,
                  ),
                ),
              ],
            ),
            if (state.pendingConfirmations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                ref.watch(
                  rcTextProvider(
                    RemoteConfigKeys.trainersHomeAwaitingApprovalSection,
                  ),
                ),
                style: typography.caption.copyWith(
                  color: colors.onWarningContainer,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final pending in state.pendingConfirmations)
                _PendingCard(
                  pending: pending,
                  doneLabel: ref.watch(
                    rcTextProvider(RemoteConfigKeys.commonTamamlandi),
                  ),
                  absentLabel: ref.watch(
                    rcTextProvider(RemoteConfigKeys.trainersHomeNoShowLabel),
                  ),
                  onDone: () => _handleCompletionAction(
                    context,
                    () => controller.markCompleted(pending.id),
                  ),
                  onAbsent: () => _handleCompletionAction(
                    context,
                    () => controller.markAbsent(pending.id),
                  ),
                ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.trainersHomeTodayScheduleSection,
                ),
              ),
              style: typography.caption.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < state.todaySchedule.length; i++)
                    _ScheduleRow(
                      slot: state.todaySchedule[i],
                      showDivider: i < state.todaySchedule.length - 1,
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

/// Hızlı onay/işaretleme aksiyonları (kart üzerindeki "Tamamlandı"/"Gelmedi"
/// ikonları) fire-and-forget çağrılıyordu — yazma başarısız olursa antrenöre
/// hiçbir geri bildirim verilmiyordu. Artık hata olursa kısa bir snackbar
/// gösteriyoruz; başarılıysa kart zaten Firestore stream'i sayesinde
/// kendiliğinden listeden düşer.
Future<void> _handleCompletionAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (_) {
    if (context.mounted) {
      final message = ProviderScope.containerOf(context).read(
        rcTextProvider(RemoteConfigKeys.trainersHomeConfirmationSaveError),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: typography.dataMedium.copyWith(
              color: valueColor,
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.pending,
    required this.doneLabel,
    required this.absentLabel,
    required this.onDone,
    required this.onAbsent,
  });

  final PendingConfirmation pending;
  final String doneLabel;
  final String absentLabel;
  final VoidCallback onDone;
  final VoidCallback onAbsent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    pending.memberInitials,
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurfaceVariant,
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
                        pending.memberName,
                        style: typography.headingSmall.copyWith(
                          color: colors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${pending.time} ${pending.meta}',
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
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      onTap: onDone,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        alignment: Alignment.center,
                        child: Text(
                          doneLabel,
                          style: typography.headingSmall.copyWith(
                            fontSize: 15,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Material(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      onTap: onAbsent,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 44),
                        alignment: Alignment.center,
                        child: Text(
                          absentLabel,
                          style: typography.headingSmall.copyWith(
                            fontSize: 15,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}

class _ScheduleRow extends ConsumerWidget {
  const _ScheduleRow({required this.slot, required this.showDivider});

  final ScheduleSlot slot;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (
      timeColor,
      barColor,
      nameColor,
      stateLabel,
      stateColor,
    ) = switch (slot.state) {
      ScheduleSlotState.completed => (
        colors.onSurfaceMuted,
        colors.success,
        colors.onSurfaceMuted,
        ref.watch(rcTextProvider(RemoteConfigKeys.commonTamamlandi)),
        colors.success,
      ),
      ScheduleSlotState.current => (
        colors.primary,
        colors.primary,
        colors.onSurface,
        ref.watch(rcTextProvider(RemoteConfigKeys.sessionsStatusNow)),
        colors.primary,
      ),
      ScheduleSlotState.absent => (
        colors.onSurfaceMuted,
        colors.warning,
        colors.onSurfaceMuted,
        ref.watch(rcTextProvider(RemoteConfigKeys.trainersHomeNoShowLabel)),
        colors.warning,
      ),
      ScheduleSlotState.cancelled => (
        colors.onSurfaceMuted,
        colors.error,
        colors.onSurfaceMuted,
        ref.watch(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
        colors.error,
      ),
      ScheduleSlotState.planned => (
        colors.onSurface,
        colors.outlineStrong,
        colors.onSurface,
        ref.watch(rcTextProvider(RemoteConfigKeys.sessionsFilterScheduled)),
        colors.onSurfaceVariant,
      ),
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 64),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 46,
            child: Text(
              slot.time,
              style: typography.headingSmall.copyWith(
                color: timeColor,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 2,
            height: 34,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot.name,
                  style: typography.headingSmall.copyWith(
                    color: nameColor,
                    fontSize: 15,
                  ),
                ),
                Text(
                  slot.meta,
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            stateLabel,
            style: typography.caption.copyWith(
              color: stateColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
