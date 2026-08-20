import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/thousands_input_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../expenses/domain/expense_state.dart';
import '../../controller/admin_calendar_controller.dart';
import '../../domain/admin_calendar_state.dart';
import '../widgets/create_session_sheet.dart';

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

/// Admin · Aylık Takvim (Seanslar sekmesi kökü) — güne tıkla → saat
/// çizelgesi, seansa tıkla → detay bottom-sheet.
class AdminCalendarPanel extends ConsumerWidget {
  const AdminCalendarPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(adminCalendarControllerProvider);
    final controller = ref.read(adminCalendarControllerProvider.notifier);
    final month = DateTime(state.selectedDate.year, state.selectedDate.month);
    final firstWeekday = month.weekday;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final selectedSlots =
        state.slotsByDayOfMonth[state.selectedDate.day] ??
        const <AdminSessionSlot>[];
    final selectedExpenses =
        state.expensesByDayOfMonth[state.selectedDate.day] ??
        const <ExpenseEntry>[];

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
                      rcTextProvider(RemoteConfigKeys.sessionsCalendarTitle),
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
                            final expenseCount =
                                state.expensesByDayOfMonth[dayNum]?.length ?? 0;
                            final hasSessions = sessionCount > 0;
                            final hasExpenses = expenseCount > 0;
                            // Seans olan günler sarı, sadece gider olan (seans
                            // olmayan) günler kırmızı yumuşak/ışımalı bir
                            // halkayla vurgulanıyor. Sağ üst rozet seans
                            // sayısı, sol üst rozet gider sayısı — ikisi de
                            // varsa aynı anda gösterilir.
                            final ringColor = hasSessions
                                ? colors.primary
                                : (hasExpenses ? colors.error : null);
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
                                      if (ringColor != null)
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: ringColor,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: ringColor.withValues(
                                                  alpha: 0.55,
                                                ),
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
                                      if (hasExpenses)
                                        Positioned(
                                          top: -6,
                                          left: -6,
                                          child: _CalendarBadge(
                                            count: expenseCount,
                                            color: colors.error,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: selectedSlots.isEmpty
                            ? Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonBuGundeSeansYok,
                                  ),
                                ),
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                              )
                            : Container(
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
                                    for (
                                      var i = 0;
                                      i < selectedSlots.length;
                                      i++
                                    )
                                      _AgendaRow(
                                        slot: selectedSlots[i],
                                        showDivider:
                                            i < selectedSlots.length - 1,
                                        onTap: () => _showSlotPopup(
                                          context,
                                          ref,
                                          selectedSlots[i],
                                          state.selectedDate,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: selectedExpenses.isEmpty
                            ? Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .sessionsCalendarNoExpensesState,
                                  ),
                                ),
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                              )
                            : Container(
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
                                    for (
                                      var i = 0;
                                      i < selectedExpenses.length;
                                      i++
                                    )
                                      _ExpenseAgendaRow(
                                        entry: selectedExpenses[i],
                                        showDivider:
                                            i < selectedExpenses.length - 1,
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSlotPopup(
    BuildContext context,
    WidgetRef ref,
    AdminSessionSlot slot,
    DateTime date,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (chipLabel, chipBg, chipFg) = switch (slot.state) {
      AdminSessionState.completed => (
        ref.read(rcTextProvider(RemoteConfigKeys.commonTamamlandi)),
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      AdminSessionState.absent => (
        ref.read(rcTextProvider(RemoteConfigKeys.trainersHomeNoShowLabel)),
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      AdminSessionState.current => (
        ref.read(rcTextProvider(RemoteConfigKeys.sessionsStatusNow)),
        colors.primaryContainer,
        colors.onPrimaryContainer,
      ),
      AdminSessionState.cancelled => (
        ref.read(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
        colors.errorContainer,
        colors.onErrorContainer,
      ),
      AdminSessionState.planned => (
        ref.read(rcTextProvider(RemoteConfigKeys.sessionsFilterScheduled)),
        colors.surfaceRaised,
        colors.onSurfaceVariant,
      ),
    };

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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                          '${date.day}',
                          style: typography.dataMedium.copyWith(
                            color: colors.onSurface,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _monthNames[date.month]!.substring(0, 3),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.title,
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          slot.meta,
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                    ),
                    child: Text(
                      chipLabel,
                      style: typography.caption.copyWith(
                        color: chipFg,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                ),
                child: Column(
                  children: [
                    _PopupRow(
                      label: ref.read(
                        rcTextProvider(
                          RemoteConfigKeys.sessionsCalendarSlotTimeLabel,
                        ),
                      ),
                      value: slot.time,
                    ),
                    _PopupRow(
                      label: ref.read(
                        rcTextProvider(
                          RemoteConfigKeys.sessionsCalendarSlotStatusLabel,
                        ),
                      ),
                      value: chipLabel,
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: ref.read(
                        rcTextProvider(RemoteConfigKeys.commonSeansiErtele),
                      ),
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        final parts = slot.time.split(':');
                        final currentStart = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          int.parse(parts[0]),
                          int.parse(parts[1]),
                        );
                        await showRescheduleSessionSheet(
                          context,
                          ref,
                          sessionId: slot.id,
                          currentStart: currentStart,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppButton(
                      label: ref.read(
                        rcTextProvider(RemoteConfigKeys.commonKapat),
                      ),
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

class _PopupRow extends StatelessWidget {
  const _PopupRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: typography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: typography.headingSmall.copyWith(
              color: colors.onSurface,
              fontSize: 14,
            ),
          ),
        ],
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

  final AdminSessionSlot slot;
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
                    slot.title,
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

class _ExpenseAgendaRow extends StatelessWidget {
  const _ExpenseAgendaRow({required this.entry, required this.showDivider});

  final ExpenseEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              entry.category,
              style: typography.bodyLarge.copyWith(
                color: colors.onSurface,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '₺${formatThousands(entry.amountTl)}',
            style: typography.headingSmall.copyWith(
              color: colors.error,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
