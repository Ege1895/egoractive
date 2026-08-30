import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/feature_flags.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../events/ui/panels/event_detail_panel.dart';
import '../../controller/discover_controller.dart';
import '../../domain/discover_item.dart';
import 'group_session_detail_panel.dart';

/// Üye 5 · Keşfet — grup dersleri / etkinlikler.
class DiscoverPanel extends ConsumerStatefulWidget {
  const DiscoverPanel({super.key});

  @override
  ConsumerState<DiscoverPanel> createState() => _DiscoverPanelState();
}

class _DiscoverPanelState extends ConsumerState<DiscoverPanel> {
  DiscoverCategory _category = DiscoverCategory.groupSessions;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final groupSessionsEnabled = ref
        .watch(featureFlagsProvider)
        .isGroupSessionsEnabled;
    final category = groupSessionsEnabled ? _category : DiscoverCategory.events;
    final items = ref
        .watch(discoverControllerProvider)
        .where((i) => i.category == category)
        .toList();
    // Antrenörler sadece görüntüler — kontenjan dolu olsa bile detay sayfası
    // her zaman açılabilir, sadece katılım akışı yok (bkz. detay panelleri).
    final isTrainer =
        ref.watch(currentRoleProvider).valueOrNull == AppRole.trainer;

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
                      rcTextProvider(
                        RemoteConfigKeys.groupSessionsDiscoverTitle,
                      ),
                    ),
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (groupSessionsEnabled)
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
                            child: _CategoryTab(
                              label: ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .groupSessionsDiscoverTabGroupSessions,
                                ),
                              ),
                              selected:
                                  category == DiscoverCategory.groupSessions,
                              onTap: () => setState(
                                () =>
                                    _category = DiscoverCategory.groupSessions,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _CategoryTab(
                              label: ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys
                                      .groupSessionsDiscoverTabEvents,
                                ),
                              ),
                              selected: category == DiscoverCategory.events,
                              onTap: () => setState(
                                () => _category = DiscoverCategory.events,
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
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        ref.watch(
                          rcTextProvider(
                            RemoteConfigKeys.groupSessionsDiscoverEmptyState,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenEdge,
                        AppSpacing.md,
                        AppSpacing.screenEdge,
                        AppSpacing.lg,
                      ),
                      children: [
                        for (final item in items)
                          _DiscoverCard(
                            item: item,
                            onTap: (!isTrainer && item.isFull)
                                ? null
                                : () => _openDetail(item),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Üye için dolu kontenjanlı bir öğenin detay sayfası hiç açılmaz —
  /// [_DiscoverCard]'a `onTap: null` geçilerek engellenir, buraya hiç
  /// gelinmez. Antrenör için bu kısıtlama yok (bkz. `isTrainer`) — sadece
  /// görüntüler, kontenjan doluluğundan bağımsız her zaman açabilir.
  void _openDetail(DiscoverItem item) {
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    if (item.category == DiscoverCategory.groupSessions) {
      panelStack.push(GroupSessionDetailPanel(groupSessionId: item.id));
    } else {
      panelStack.push(EventDetailPanel(eventId: item.id));
    }
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
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

/// Egoractive Keşfet ekranı — kart artık katıl/vazgeç düğmesi içermiyor,
/// sadece özet bilgi + detay sayfasına giden bir ok. Katılım işlemi
/// [GroupSessionDetailPanel]/[EventDetailPanel]'e taşındı. Kontenjanı dolu
/// bir öğenin oku gösterilmez, kart tıklanamaz — detay sayfası hiç açılmaz.
class _DiscoverCard extends ConsumerWidget {
  const _DiscoverCard({required this.item, required this.onTap});

  final DiscoverItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final capacity = item.capacity;
    final remaining = capacity == null ? null : capacity - item.taken;

    final Color capFg;
    final Color barColor;
    final String capNote;
    if (item.isFull) {
      capFg = colors.error;
      barColor = colors.error;
      capNote = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsCapacityFullNote),
      );
    } else if (remaining != null && remaining <= 2) {
      capFg = colors.onWarningContainer;
      barColor = colors.warning;
      capNote = ref
          .watch(rcTextProvider(RemoteConfigKeys.groupSessionsCapacityLowNote))
          .replaceAll('{remaining}', '$remaining');
    } else {
      capFg = colors.onSurfaceVariant;
      barColor = colors.primary;
      capNote = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsCapacityAvailableNote),
      );
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
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
                          item.day,
                          style: typography.dataMedium.copyWith(
                            color: colors.onSurface,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          item.month,
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
                          item.title,
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                          ),
                        ),
                        Text(
                          item.meta,
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.chevron_right,
                      color: colors.onSurfaceMuted,
                      size: 22,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      capacity == null
                          ? ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsAttendingCountNoCapacity,
                                  ),
                                )
                                .replaceAll('{taken}', '${item.taken}')
                          : ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsAttendingCountWithCapacity,
                                  ),
                                )
                                .replaceAll('{taken}', '${item.taken}')
                                .replaceAll('{capacity}', '$capacity'),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    capNote,
                    style: typography.headingSmall.copyWith(
                      color: capFg,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: LinearProgressIndicator(
                  value: capacity == null
                      ? 0
                      : (item.taken / capacity).clamp(0, 1),
                  minHeight: 6,
                  backgroundColor: colors.surfaceRaised,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
