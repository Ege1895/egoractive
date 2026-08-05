import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
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
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Etkinlikler', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      onTap: () => ref.read(panelStackControllerProvider.notifier).push(const CreateEventPanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text('+ Etkinlik', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  for (final event in events) _EventCard(event: event),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final GymEvent event;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
                child: Column(
                  children: [
                    Text(event.day, style: typography.dataMedium.copyWith(color: colors.onSurface, fontSize: 20)),
                    Text(event.month, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.name, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 17)),
                    Text(event.meta, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
                  child: Row(
                    children: [
                      Expanded(child: Text('Katılan', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12))),
                      Text('${event.joined}', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
                  child: Row(
                    children: [
                      Expanded(child: Text('Kontenjan', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12))),
                      Text(event.capacityLabel, style: typography.headingSmall.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
                    ],
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
