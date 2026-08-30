import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/gym_events_controller.dart';
import '../../domain/gym_event.dart';
import 'create_event_panel.dart';

/// Admin 12 · Etkinlikler — liste.
class AdminEventsPanel extends BasePanel {
  const AdminEventsPanel({super.key});

  @override
  ConsumerState<AdminEventsPanel> createState() => _AdminEventsPanelState();
}

class _AdminEventsPanelState extends BasePanelState<AdminEventsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final events = ref.watch(gymEventsControllerProvider);

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
                  Expanded(
                    child: Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.eventsAdminListTitle),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(const CreateEventPanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.eventsAddEventButton,
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
                  for (final event in events)
                    _EventCard(
                      event: event,
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(CreateEventPanel(eventId: event.id)),
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

class _EventCard extends ConsumerWidget {
  const _EventCard({required this.event, required this.onTap});

  final GymEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.outline),
          ),
          child: Opacity(
            opacity: event.isCancelled ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(
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
                            event.day,
                            style: typography.dataMedium.copyWith(
                              color: colors.onSurface,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            event.month,
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
                            event.name,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            event.meta,
                            style: typography.bodyMedium.copyWith(
                              color: colors.onSurfaceMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (event.isCancelled)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.errorContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                        ),
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.groupSessionsCancelledBadge,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.error,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right,
                      color: colors.onSurfaceMuted,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Container(
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsAttendingLabel,
                                  ),
                                ),
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${event.joined}',
                              style: typography.headingSmall.copyWith(
                                color: colors.onSurface,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCapacityLabel,
                                  ),
                                ),
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              event.capacityLabel,
                              style: typography.headingSmall.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 15,
                              ),
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
        ),
      ),
    );
  }
}
