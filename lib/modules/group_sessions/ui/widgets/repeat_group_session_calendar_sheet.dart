import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/date_labels.dart';

/// "Grup dersi oluştur" ekranındaki "Tekrarla" — seanslardaki
/// `repeat_session_calendar_sheet.dart` ile aynı görsel dil (üzerinde +
/// olan bir ay takvimi), ama üyenin kalan ders hakkına bağlı bir üst sınır
/// YOK — admin/antrenör geçmiş olmayan istediği kadar günü seçebilir. Ana
/// tarih (`baseDate`) takvimde ayrıca işaretlenir ama seçilemez/kaldırılamaz
/// — o zaten "Tarih" alanından geliyor.
Future<List<DateTime>?> showRepeatGroupSessionCalendarSheet(
  BuildContext context, {
  required DateTime baseDate,
  required List<DateTime> initiallySelected,
}) {
  return showModalBottomSheet<List<DateTime>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _RepeatGroupSessionCalendarSheet(
      baseDate: baseDate,
      initiallySelected: initiallySelected,
    ),
  );
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class _RepeatGroupSessionCalendarSheet extends ConsumerStatefulWidget {
  const _RepeatGroupSessionCalendarSheet({
    required this.baseDate,
    required this.initiallySelected,
  });

  final DateTime baseDate;
  final List<DateTime> initiallySelected;

  @override
  ConsumerState<_RepeatGroupSessionCalendarSheet> createState() =>
      _RepeatGroupSessionCalendarSheetState();
}

class _RepeatGroupSessionCalendarSheetState
    extends ConsumerState<_RepeatGroupSessionCalendarSheet> {
  late DateTime _month;
  late List<DateTime> _selected;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.baseDate.year, widget.baseDate.month);
    _selected = List.of(widget.initiallySelected);
  }

  void _toggleDay(DateTime day) {
    final index = _selected.indexWhere((d) => _isSameDay(d, day));
    setState(() {
      if (index != -1) {
        _selected.removeAt(index);
      } else {
        _selected.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final today = DateTime.now();
    final firstWeekday = _month.weekday;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineStrong,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsCreateRepeatLabel),
            ),
            style: typography.headingMedium.copyWith(
              color: colors.onSurface,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsRepeatCalendarSubtitle),
            ),
            style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      ),
                      icon: Icon(
                        Icons.chevron_left,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      ref.watch(dateLabelsProvider).monthYear(_month),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      ),
                      icon: Icon(
                        Icons.chevron_right,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    for (final name
                        in ref.watch(dateLabelsProvider).weekdayInitialList)
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
                const SizedBox(height: AppSpacing.xs),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalCells,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    final dayNum = index - leadingBlanks + 1;
                    if (dayNum < 1 || dayNum > daysInMonth) {
                      return const SizedBox.shrink();
                    }
                    final date = DateTime(_month.year, _month.month, dayNum);
                    final isBaseDate = _isSameDay(date, widget.baseDate);
                    final isPast =
                        date.isBefore(
                          DateTime(today.year, today.month, today.day),
                        ) &&
                        !isBaseDate;
                    final isSelected = _selected.any(
                      (d) => _isSameDay(d, date),
                    );

                    return _DayCell(
                      day: dayNum,
                      state: isBaseDate
                          ? _DayCellState.base
                          : isPast
                          ? _DayCellState.disabled
                          : isSelected
                          ? _DayCellState.selected
                          : _DayCellState.available,
                      onTap: isBaseDate || isPast
                          ? null
                          : () => _toggleDay(date),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Material(
            color: colors.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              onTap: () => Navigator.of(context).pop(_selected),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                alignment: Alignment.center,
                child: Text(
                  ref.watch(
                    rcTextProvider(
                      RemoteConfigKeys.sessionsCreateSelectPlaceholder,
                    ),
                  ),
                  style: typography.headingSmall.copyWith(
                    fontSize: 16,
                    color: colors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _DayCellState { available, selected, base, disabled }

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.state, this.onTap});

  final int day;
  final _DayCellState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    final (Color background, Color foreground, Widget icon) = switch (state) {
      _DayCellState.selected => (
        colors.primary,
        colors.onPrimary,
        Icon(Icons.check, size: 14, color: colors.onPrimary),
      ),
      _DayCellState.base => (
        colors.surface,
        colors.onSurfaceMuted,
        const SizedBox.shrink(),
      ),
      _DayCellState.disabled => (
        Colors.transparent,
        colors.onSurfaceMuted.withValues(alpha: 0.4),
        const SizedBox.shrink(),
      ),
      _DayCellState.available => (
        colors.surface,
        colors.onSurfaceVariant,
        Icon(Icons.add, size: 14, color: colors.onSurfaceVariant),
      ),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$day',
            style: typography.caption.copyWith(
              color: state == _DayCellState.disabled
                  ? colors.onSurfaceMuted.withValues(alpha: 0.4)
                  : colors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
              border: Border.all(
                color: state == _DayCellState.base
                    ? colors.outlineStrong
                    : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: icon,
          ),
        ],
      ),
    );
  }
}
