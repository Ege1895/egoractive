import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/mock/trainer_mock_data.dart';
import '../../../sessions/ui/panels/session_completion_panel.dart';
import '../../../sessions/ui/panels/trainer_notifications_panel.dart';
import '../../controller/trainer_home_controller.dart';
import '../../domain/pending_confirmation.dart';
import '../../domain/schedule_slot.dart';

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
                    TrainerMockData.trainerInitials,
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
                        'Pazartesi, 3 Ağustos',
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                      Text(
                        'İyi çalışmalar ${TrainerMockData.trainerName.split(' ').first}',
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
                    label: 'Bugünkü seans',
                    value: '${state.todaySessionCount}',
                    valueColor: colors.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatTile(
                    label: 'Tamamlanan',
                    value: '${state.completedCount}',
                    valueColor: colors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatTile(
                    label: 'Boş saat',
                    value: '${state.freeSlotCount}',
                    valueColor: colors.onSurface,
                  ),
                ),
              ],
            ),
            if (state.pendingConfirmations.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'ONAYINIZI BEKLİYOR',
                style: typography.caption.copyWith(
                  color: colors.onWarningContainer,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final pending in state.pendingConfirmations)
                _PendingCard(
                  pending: pending,
                  onTap: () => panelStack.push(
                    SessionCompletionPanel(
                      time: pending.time,
                      memberInitials: pending.memberInitials,
                      memberName: pending.memberName,
                      meta: pending.meta,
                      remainingBefore: pending.remainingBefore,
                      sessionId: pending.id,
                      memberId: pending.memberId,
                    ),
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
              'BUGÜNKÜ PROGRAMINIZ',
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Onay kaydedilemedi, bağlantını kontrol edip tekrar dene.',
          ),
        ),
      );
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
    required this.onTap,
    required this.onDone,
    required this.onAbsent,
  });

  final PendingConfirmation pending;
  final VoidCallback onTap;
  final VoidCallback onDone;
  final VoidCallback onAbsent;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: onTap,
      child: Container(
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
                          'Tamamlandı',
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
                          'Gelmedi',
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
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.slot, required this.showDivider});

  final ScheduleSlot slot;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
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
        'Tamamlandı',
        colors.success,
      ),
      ScheduleSlotState.current => (
        colors.primary,
        colors.primary,
        colors.onSurface,
        'Şimdi',
        colors.primary,
      ),
      ScheduleSlotState.cancelled => (
        colors.onSurfaceMuted,
        colors.error,
        colors.onSurfaceMuted,
        'İptal',
        colors.error,
      ),
      ScheduleSlotState.planned => (
        colors.onSurface,
        colors.outlineStrong,
        colors.onSurface,
        'Planlandı',
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
