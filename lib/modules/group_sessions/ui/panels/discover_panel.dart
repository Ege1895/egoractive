import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/feature_flags.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/discover_controller.dart';
import '../../domain/discover_item.dart';

/// Üye 5 · Keşfet — grup dersleri / etkinlikler.
class DiscoverPanel extends ConsumerStatefulWidget {
  const DiscoverPanel({super.key});

  @override
  ConsumerState<DiscoverPanel> createState() => _DiscoverPanelState();
}

class _DiscoverPanelState extends ConsumerState<DiscoverPanel> {
  DiscoverCategory _category = DiscoverCategory.groupSessions;
  final Set<String> _pendingIds = {};

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
    final controller = ref.read(discoverControllerProvider.notifier);

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
                            isPending: _pendingIds.contains(item.id),
                            onToggleJoin: () =>
                                _onToggleJoin(item.id, controller),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Firestore yazması bitene kadar (network gecikmesi dahil) düğme
  /// gösterge olmadan öylece duruyordu — üye "hiçbir şey olmadı" sanıp
  /// birden fazla kez dokunuyordu. `_pendingIds`, sadece dokunulan
  /// kartın düğmesini geçici olarak devre dışı bırakıp bir spinner
  /// gösteriyor.
  Future<void> _onToggleJoin(
    String itemId,
    DiscoverController controller,
  ) async {
    setState(() => _pendingIds.add(itemId));
    try {
      await _handleToggleJoin(context, () => controller.toggleJoin(itemId));
    } finally {
      if (mounted) setState(() => _pendingIds.remove(itemId));
    }
  }
}

/// Katıl/ayrıl hatası (kontenjan dolu, network) daha önce sessizce
/// yutuluyordu — üye butona basıyor, hiçbir şey olmuyordu. Artık kısa bir
/// snackbar ile açıklanıyor.
Future<void> _handleToggleJoin(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error) {
    if (!context.mounted) return;
    final container = ProviderScope.containerOf(context);
    final message = error is StateError && error.message == 'Kontenjan doldu.'
        ? container.read(
            rcTextProvider(RemoteConfigKeys.groupSessionsJoinFullErrorSnackbar),
          )
        : container.read(
            rcTextProvider(RemoteConfigKeys.groupSessionsJoinFailedSnackbar),
          );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

class _DiscoverCard extends ConsumerWidget {
  const _DiscoverCard({
    required this.item,
    required this.isPending,
    required this.onToggleJoin,
  });

  final DiscoverItem item;
  final bool isPending;
  final VoidCallback onToggleJoin;

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

    final String btnLabel;
    final Color btnBg;
    final Color btnFg;
    if (item.isFull && !item.joined) {
      btnLabel = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsWaitlistJoinButton),
      );
      btnBg = colors.surfaceRaised;
      btnFg = colors.onSurfaceVariant;
    } else if (item.joined && !item.canLeave) {
      btnLabel = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsJoinedLockedButton),
      );
      btnBg = colors.primaryContainer;
      btnFg = colors.onPrimaryContainer;
    } else if (item.joined) {
      btnLabel = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsJoinedLeaveButton),
      );
      btnBg = colors.primaryContainer;
      btnFg = colors.onPrimaryContainer;
    } else {
      btnLabel = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsJoinButton),
      );
      btnBg = colors.primary;
      btnFg = colors.onPrimary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
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
              value: capacity == null ? 0 : (item.taken / capacity).clamp(0, 1),
              minHeight: 6,
              backgroundColor: colors.surfaceRaised,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Material(
            color: btnBg,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            child: InkWell(
              onTap: (isPending || (item.joined && !item.canLeave))
                  ? null
                  : onToggleJoin,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                alignment: Alignment.center,
                child: isPending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(btnFg),
                        ),
                      )
                    : Text(
                        btnLabel,
                        style: typography.headingSmall.copyWith(
                          fontSize: 15,
                          color: btnFg,
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
