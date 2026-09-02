import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/sessions_controller.dart';
import '../../domain/session.dart';
import '../../domain/sessions_state.dart';
import '../../../../shared/utils/date_labels.dart';

/// Üye · Derslerim — liste / takvim geçişi.
class SessionsListPanel extends ConsumerStatefulWidget {
  const SessionsListPanel({super.key});

  @override
  ConsumerState<SessionsListPanel> createState() => _SessionsListPanelState();
}

class _SessionsListPanelState extends ConsumerState<SessionsListPanel> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(sessionsControllerProvider);
    final controller = ref.read(sessionsControllerProvider.notifier);

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
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.sessionsListTitle),
                    ),
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                    ),
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
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.sessionsListViewToggle,
                              ),
                            ),
                            selected: state.viewMode == SessionsViewMode.list,
                            onTap: () =>
                                controller.setViewMode(SessionsViewMode.list),
                          ),
                        ),
                        Expanded(
                          child: _ToggleTab(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.sessionsCalendarViewToggle,
                              ),
                            ),
                            selected:
                                state.viewMode == SessionsViewMode.calendar,
                            onTap: () => controller.setViewMode(
                              SessionsViewMode.calendar,
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
              child: state.viewMode == SessionsViewMode.list
                  ? _SessionsListView(
                      upcoming: state.upcoming,
                      past: state.past,
                    )
                  : _SessionsCalendarView(
                      selectedDay: _selectedDay,
                      sessions: [...state.upcoming, ...state.past],
                      onSelectDay: (day) => setState(() => _selectedDay = day),
                    ),
            ),
          ],
        ),
      ),
    );
  }
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

class _SessionsListView extends ConsumerWidget {
  const _SessionsListView({required this.upcoming, required this.past});

  final List<Session> upcoming;
  final List<Session> past;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    if (upcoming.isEmpty && past.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          child: Text(
            ref.watch(rcTextProvider(RemoteConfigKeys.sessionsListEmptyState)),
            textAlign: TextAlign.center,
            style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.lg,
      ),
      children: [
        if (upcoming.isNotEmpty) ...[
          Text(
            ref.watch(rcTextProvider(RemoteConfigKeys.sessionsUpcomingSection)),
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final session in upcoming) _SessionRow(session: session),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (past.isNotEmpty) ...[
          Text(
            ref.watch(rcTextProvider(RemoteConfigKeys.sessionsPastSection)),
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final session in past)
            _SessionRow(session: session, faded: true),
        ],
      ],
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session, this.faded = false});

  final Session session;
  final bool faded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (chipLabel, chipBg, chipFg) = switch (session.status) {
      SessionStatus.planned => (
        ref.watch(rcTextProvider(RemoteConfigKeys.sessionsFilterScheduled)),
        colors.outline,
        colors.onSurfaceVariant,
      ),
      SessionStatus.completed => (
        ref.watch(rcTextProvider(RemoteConfigKeys.commonTamamlandi)),
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      SessionStatus.absent => (
        ref.watch(rcTextProvider(RemoteConfigKeys.trainersHomeNoShowLabel)),
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      SessionStatus.cancelled => (
        ref.watch(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };

    return Opacity(
      opacity: faded ? 0.7 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              ),
              child: Column(
                children: [
                  Text(
                    session.day,
                    style: typography.dataMedium.copyWith(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    session.month,
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
                    session.title,
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    session.meta,
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
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                chipLabel,
                style: typography.caption.copyWith(color: chipFg, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionsCalendarView extends ConsumerWidget {
  const _SessionsCalendarView({
    required this.selectedDay,
    required this.sessions,
    required this.onSelectDay,
  });

  final DateTime selectedDay;
  final List<Session> sessions;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final month = DateTime(selectedDay.year, selectedDay.month);
    final firstWeekday = month.weekday; // 1=Pzt
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;

    final sessionsByDay = <int, List<Session>>{};
    for (final session in sessions) {
      final day = int.tryParse(session.day);
      if (day != null) sessionsByDay.putIfAbsent(day, () => []).add(session);
    }
    final daySessions = sessionsByDay[selectedDay.day] ?? const <Session>[];

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${ref.watch(dateLabelsProvider).monthShort(month.month)} ${month.year}',
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 17,
                    ),
                  ),
                  Row(
                    children: [
                      _ArrowButton(
                        icon: Icons.chevron_left,
                        onTap: () => onSelectDay(
                          DateTime(month.year, month.month - 1, 1),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _ArrowButton(
                        icon: Icons.chevron_right,
                        onTap: () => onSelectDay(
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
                  for (final name
                      in ref.watch(dateLabelsProvider).weekdayShortList)
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
                  final isSelected = date.day == selectedDay.day;
                  final count = sessionsByDay[dayNum]?.length ?? 0;
                  final hasSessions = count > 0;
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
                                      color: colors.primary.withValues(
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
                                  count: count,
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
          ref.watch(dateLabelsProvider).dayMonthShort(selectedDay),
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (daySessions.isEmpty)
          Text(
            ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsListCalendarEmptyDay),
            ),
            style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          )
        else
          for (final session in daySessions) _SessionRow(session: session),
      ],
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
