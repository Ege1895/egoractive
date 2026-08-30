import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/admin_group_sessions_controller.dart';
import '../../domain/admin_group_session.dart';
import 'create_group_session_panel.dart';

/// Admin 11 · Grup Dersleri — kontenjan doluluk göstergesi, + Grup dersi.
class AdminGroupSessionsPanel extends BasePanel {
  const AdminGroupSessionsPanel({super.key});

  @override
  ConsumerState<AdminGroupSessionsPanel> createState() =>
      _AdminGroupSessionsPanelState();
}

class _AdminGroupSessionsPanelState
    extends BasePanelState<AdminGroupSessionsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final groups = ref.watch(adminGroupSessionsControllerProvider);

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
                        rcTextProvider(
                          RemoteConfigKeys.groupSessionsAdminListTitle,
                        ),
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
                          .push(const CreateGroupSessionPanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .groupSessionsAddGroupSessionButton,
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
                  for (final group in groups)
                    _GroupCard(
                      group: group,
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(
                            CreateGroupSessionPanel(groupSessionId: group.id),
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
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group, required this.onTap});

  final AdminGroupSession group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final ratio = group.capacity == 0 ? 0.0 : group.taken / group.capacity;
    final (capFg, barColor, note) = group.isFull
        ? (
            colors.error,
            colors.error,
            ref.watch(
              rcTextProvider(RemoteConfigKeys.groupSessionsCapacityFullNote),
            ),
          )
        : group.remaining <= 2
        ? (
            colors.onWarningContainer,
            colors.warning,
            ref
                .watch(
                  rcTextProvider(RemoteConfigKeys.groupSessionsCapacityLowNote),
                )
                .replaceAll('{remaining}', '${group.remaining}'),
          )
        : (
            colors.onSurfaceMuted,
            colors.primary,
            ref.watch(
              rcTextProvider(
                RemoteConfigKeys.groupSessionsCapacityAvailableNote,
              ),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
            ),
            child: Opacity(
              opacity: group.isCancelled ? 0.55 : 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    group.meta,
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (group.isCancelled)
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
                                      RemoteConfigKeys
                                          .groupSessionsCancelledBadge,
                                    ),
                                  ),
                                  style: typography.caption.copyWith(
                                    color: colors.error,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${group.taken}/${group.capacity}',
                                    style: typography.dataMedium.copyWith(
                                      color: capFg,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .groupSessionsCapacitySuffixLabel,
                                      ),
                                    ),
                                    style: typography.caption.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        if (!group.isCancelled) ...[
                          const SizedBox(height: AppSpacing.md),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                            child: LinearProgressIndicator(
                              value: ratio.clamp(0, 1),
                              minHeight: 8,
                              backgroundColor: colors.surfaceRaised,
                              valueColor: AlwaysStoppedAnimation(barColor),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  note,
                                  style: typography.bodyMedium.copyWith(
                                    color: capFg,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceMuted,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
