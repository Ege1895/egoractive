import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/feature_flags.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../group_sessions/ui/panels/create_group_session_panel.dart';
import '../../../sessions/ui/panels/session_completion_panel.dart';
import '../../controller/trainer_calendar_controller.dart';
import '../../domain/schedule_slot.dart';
import '../../domain/trainer_calendar_state.dart';

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

/// Antrenör 5 · Takvimim (Takvimim sekmesi kökü) — hafta / ay geçişi.
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
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    final groupSessionsEnabled = ref
        .watch(featureFlagsProvider)
        .isGroupSessionsEnabled;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Takvimim',
                        style: typography.headingLarge.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      if (groupSessionsEnabled)
                        Material(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            onTap: () => panelStack.push(
                              const CreateGroupSessionPanel(),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              child: Icon(Icons.add, color: colors.onPrimary),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _ToggleTab(
                            label: 'Hafta',
                            selected:
                                state.viewMode == TrainerCalendarViewMode.week,
                            onTap: () => controller.setViewMode(
                              TrainerCalendarViewMode.week,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _ToggleTab(
                            label: 'Ay',
                            selected:
                                state.viewMode == TrainerCalendarViewMode.month,
                            onTap: () => controller.setViewMode(
                              TrainerCalendarViewMode.month,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.viewMode == TrainerCalendarViewMode.week
                  ? _WeekView(
                      state: state,
                      onSlotTap: (slot) => _showSlotDetail(context, slot),
                    )
                  : _MonthView(
                      state: state,
                      onSelectDay: controller.selectDate,
                      onSlotTap: (slot) => _showSlotDetail(context, slot),
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
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Tamamlandı işaretle',
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
                      label: 'Kapat',
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ),
                ],
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

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.surfaceRaised : Colors.transparent,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({required this.state, required this.onSlotTap});

  final TrainerCalendarState state;
  final ValueChanged<ScheduleSlot> onSlotTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final weekStart = state.selectedDate.subtract(
      Duration(days: state.selectedDate.weekday - 1),
    );
    final days = [for (var i = 0; i < 7; i++) weekStart.add(Duration(days: i))];
    final weekNumber =
        ((state.selectedDate
                    .difference(DateTime(state.selectedDate.year))
                    .inDays) /
                7)
            .ceil() +
        1;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.lg,
      ),
      children: [
        Text(
          '${days.first.day} – ${days.last.day} ${_monthNames[days.last.month]} · $weekNumber. hafta',
          style: typography.headingSmall.copyWith(
            color: colors.onSurface,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final day in days)
          _WeekDayCard(
            day: day,
            slots: state.slotsByDayOfMonth[day.day] ?? const [],
            onSlotTap: onSlotTap,
          ),
      ],
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({
    required this.day,
    required this.slots,
    required this.onSlotTap,
  });

  final DateTime day;
  final List<ScheduleSlot> slots;
  final ValueChanged<ScheduleSlot> onSlotTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final isToday = day.year == 2026 && day.month == 8 && day.day == 3;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: isToday ? colors.primary : colors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 42,
            child: Column(
              children: [
                Text(
                  '${day.day}',
                  style: typography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 19,
                  ),
                ),
                Text(
                  _dayNames[day.weekday - 1],
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: slots.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      'Seans yok — bu güne seans ekleyebilirsiniz',
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 13,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final slot in slots)
                        _SlotRow(slot: slot, onTap: () => onSlotTap(slot)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.onTap});

  final ScheduleSlot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final accent = switch (slot.state) {
      ScheduleSlotState.completed => colors.success,
      ScheduleSlotState.cancelled => colors.error,
      ScheduleSlotState.current => colors.primary,
      ScheduleSlotState.planned => colors.onSurfaceVariant,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  slot.time,
                  style: typography.headingSmall.copyWith(
                    color: accent,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    slot.name,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.state,
    required this.onSelectDay,
    required this.onSlotTap,
  });

  final TrainerCalendarState state;
  final ValueChanged<DateTime> onSelectDay;
  final ValueChanged<ScheduleSlot> onSlotTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final month = DateTime(state.selectedDate.year, state.selectedDate.month);
    final firstWeekday = month.weekday;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final selectedSlots =
        state.slotsByDayOfMonth[state.selectedDate.day] ??
        const <ScheduleSlot>[];

    return ListView(
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
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.outline),
          ),
          child: Column(
            children: [
              Text(
                '${_monthNames[month.month]} ${month.year}',
                style: typography.headingSmall.copyWith(
                  color: colors.onSurface,
                  fontSize: 17,
                ),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  final dayNum = index - leadingBlanks + 1;
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime(month.year, month.month, dayNum);
                  final isSelected = date.day == state.selectedDate.day;
                  final count = state.slotsByDayOfMonth[dayNum]?.length ?? 0;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSelectDay(date),
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: typography.headingSmall.copyWith(
                              fontSize: 14,
                              color: isSelected
                                  ? colors.onPrimaryContainer
                                  : colors.onSurface,
                            ),
                          ),
                          if (count > 0)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                '$count',
                                style: typography.caption.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontSize: 9,
                                ),
                              ),
                            ),
                        ],
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
            'Bu günde seans yok.',
            style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                for (var i = 0; i < selectedSlots.length; i++)
                  _AgendaRow(
                    slot: selectedSlots[i],
                    showDivider: i < selectedSlots.length - 1,
                    onTap: () => onSlotTap(selectedSlots[i]),
                  ),
              ],
            ),
          ),
      ],
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
