import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../sessions/ui/panels/session_completion_panel.dart';
import '../../../sessions/ui/widgets/create_session_sheet.dart';
import '../../controller/trainer_calendar_controller.dart';
import '../../domain/schedule_slot.dart';

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
const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Antrenör 5 · Takvimim (Takvimim sekmesi kökü) — admin'in aylık
/// takvimiyle (bkz. admin_calendar_panel.dart) birebir aynı tasarım:
/// ay ızgarası + gün altında ajanda listesi, hafta/ay geçişi yok.
class TrainerCalendarPanel extends BasePanel {
  const TrainerCalendarPanel({super.key});

  @override
  ConsumerState<TrainerCalendarPanel> createState() =>
      _TrainerCalendarPanelState();
}

class _TrainerCalendarPanelState extends BasePanelState<TrainerCalendarPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(trainerCalendarControllerProvider);
    final controller = ref.read(trainerCalendarControllerProvider.notifier);
    final month = DateTime(state.selectedDate.year, state.selectedDate.month);
    final firstWeekday = month.weekday;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final selectedSlots =
        state.slotsByDayOfMonth[state.selectedDate.day] ??
        const <ScheduleSlot>[];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.trainersCalendarTitle),
                    ),
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      onTap: () => showCreateSessionSheet(
                        context,
                        ref,
                        state.selectedDate,
                        lockedTrainerId: ref
                            .read(authStateProvider)
                            .valueOrNull
                            ?.uid,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.commonAddSeansButton,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            fontSize: 14,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_monthNames[month.month]} ${month.year}',
                              style: typography.headingSmall.copyWith(
                                color: colors.onSurface,
                                fontSize: 17,
                              ),
                            ),
                            Row(
                              children: [
                                _ArrowButton(
                                  icon: Icons.chevron_left,
                                  onTap: () => controller.selectDate(
                                    DateTime(month.year, month.month - 1, 1),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _ArrowButton(
                                  icon: Icons.chevron_right,
                                  onTap: () => controller.selectDate(
                                    DateTime(month.year, month.month + 1, 1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final name in _dayNames)
                              Expanded(
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: typography.caption.copyWith(
                                    color: colors.onSurfaceMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: totalCells,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                              ),
                          itemBuilder: (context, index) {
                            final dayNum = index - leadingBlanks + 1;
                            if (dayNum < 1 || dayNum > daysInMonth) {
                              return const SizedBox.shrink();
                            }
                            final date = DateTime(
                              month.year,
                              month.month,
                              dayNum,
                            );
                            final isSelected =
                                date.day == state.selectedDate.day;
                            final sessionCount =
                                state.slotsByDayOfMonth[dayNum]?.length ?? 0;
                            final hasSessions = sessionCount > 0;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => controller.selectDate(date),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      if (hasSessions)
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colors.primary,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.primary
                                                    .withValues(alpha: 0.55),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        '$dayNum',
                                        style: typography.headingSmall.copyWith(
                                          fontSize: 14,
                                          color: isSelected
                                              ? colors.onPrimaryContainer
                                              : colors.onSurface,
                                        ),
                                      ),
                                      if (hasSessions)
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: _CalendarBadge(
                                            count: sessionCount,
                                            color: colors.primary,
                                            onColor: colors.onPrimary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${state.selectedDate.day} ${_monthNames[state.selectedDate.month]}',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (selectedSlots.isEmpty)
                    Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.commonBuGundeSeansYok),
                      ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < selectedSlots.length; i++)
                            _AgendaRow(
                              slot: selectedSlots[i],
                              showDivider: i < selectedSlots.length - 1,
                              onTap: () =>
                                  _showSlotDetail(context, selectedSlots[i]),
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
    );
  }

  void _showSlotDetail(BuildContext context, ScheduleSlot slot) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final markCompletedLabel = ref.read(
      rcTextProvider(RemoteConfigKeys.trainersCalendarMarkCompletedAction),
    );
    final closeLabel = ref.read(rcTextProvider(RemoteConfigKeys.commonKapat));
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.lg,
            AppSpacing.screenEdge,
            AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Text(
                      slot.time,
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
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
                          slot.name,
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          slot.meta,
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Zaten tamamlanmış/iptal edilmiş bir seansta "Dersi onayla"
              // butonu gösterilmeye devam ediyordu — dokununca
              // isCompletingOwnSession() kuralı (status == 'planned' şartı)
              // PERMISSION_DENIED ile reddediyor, kullanıcıya anlamsız bir
              // hata olarak görünüyordu. Sadece henüz onaylanmamış
              // (planned/current) seanslarda gösteriliyor artık.
              if (slot.state == ScheduleSlotState.planned ||
                  slot.state == ScheduleSlotState.current)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: markCompletedLabel,
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          // slot.id/memberId sadece gerçek Firestore
                          // verisinden geliyorsa dolu (bkz. #114) — mock
                          // fallback'te boş kalıp eski (yazma yapmayan)
                          // önizleme davranışına düşer.
                          var remainingBefore = 0;
                          if (slot.memberId.isNotEmpty) {
                            final memberDoc = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(slot.memberId)
                                .get();
                            remainingBefore =
                                (memberDoc.data()?['remainingSessions'] as num?)
                                    ?.toInt() ??
                                0;
                          }
                          if (!context.mounted) return;
                          ref
                              .read(panelStackControllerProvider.notifier)
                              .push(
                                SessionCompletionPanel(
                                  time: slot.time,
                                  memberInitials: _initialsOf(slot.name),
                                  memberName: slot.name,
                                  meta: slot.meta,
                                  remainingBefore: remainingBefore,
                                  sessionId: slot.memberId.isEmpty
                                      ? null
                                      : slot.id,
                                  memberId: slot.memberId.isEmpty
                                      ? null
                                      : slot.memberId,
                                ),
                              );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: closeLabel,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                      ),
                    ),
                  ],
                )
              else
                AppButton(
                  label: closeLabel,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, color: colors.onSurfaceVariant, size: 18),
        ),
      ),
    );
  }
}

class _CalendarBadge extends StatelessWidget {
  const _CalendarBadge({
    required this.count,
    required this.color,
    required this.onColor,
  });

  final int count;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: context.appTypography.caption.copyWith(
          color: onColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _AgendaRow extends StatelessWidget {
  const _AgendaRow({
    required this.slot,
    required this.showDivider,
    required this.onTap,
  });

  final ScheduleSlot slot;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: colors.outline))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                slot.time,
                style: typography.headingSmall.copyWith(
                  color: colors.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.name,
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurface,
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
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
