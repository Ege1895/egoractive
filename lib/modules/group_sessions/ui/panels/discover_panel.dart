import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final items = ref.watch(discoverControllerProvider).where((i) => i.category == _category).toList();
    final controller = ref.read(discoverControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Keşfet', style: typography.headingLarge.copyWith(color: colors.onSurface)),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CategoryTab(
                            label: 'Grup dersleri',
                            selected: _category == DiscoverCategory.groupSessions,
                            onTap: () => setState(() => _category = DiscoverCategory.groupSessions),
                          ),
                        ),
                        Expanded(
                          child: _CategoryTab(
                            label: 'Etkinlikler',
                            selected: _category == DiscoverCategory.events,
                            onTap: () => setState(() => _category = DiscoverCategory.events),
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
                        'Şu anda açık kayıt yok — yeni bir tarih eklendiğinde burada görünecek.',
                        textAlign: TextAlign.center,
                        style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                      children: [
                        for (final item in items) _DiscoverCard(item: item, onToggleJoin: () => controller.toggleJoin(item.id)),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({required this.label, required this.selected, required this.onTap});

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

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({required this.item, required this.onToggleJoin});

  final DiscoverItem item;
  final VoidCallback onToggleJoin;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final remaining = item.capacity - item.taken;

    final Color capFg;
    final Color barColor;
    final String capNote;
    if (item.isFull) {
      capFg = colors.error;
      barColor = colors.error;
      capNote = 'Kontenjan doldu';
    } else if (remaining <= 2) {
      capFg = colors.onWarningContainer;
      barColor = colors.warning;
      capNote = 'Son $remaining yer';
    } else {
      capFg = colors.onSurfaceVariant;
      barColor = colors.primary;
      capNote = 'Yer var';
    }

    final String btnLabel;
    final Color btnBg;
    final Color btnFg;
    if (item.isFull) {
      btnLabel = 'Yedek listesine yaz';
      btnBg = colors.surfaceRaised;
      btnFg = colors.onSurfaceVariant;
    } else if (item.joined) {
      btnLabel = 'Katılıyorsun · Vazgeç';
      btnBg = colors.primaryContainer;
      btnFg = colors.onPrimaryContainer;
    } else {
      btnLabel = 'Katılıyorum';
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
                    Text(item.day, style: typography.dataMedium.copyWith(color: colors.onSurface, fontSize: 20)),
                    Text(item.month, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: typography.headingSmall.copyWith(color: colors.onSurface)),
                    Text(item.meta, style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 13)),
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
                  '${item.taken} / ${item.capacity} kişi',
                  style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 13),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(capNote, style: typography.headingSmall.copyWith(color: capFg, fontSize: 13)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(
              value: (item.taken / item.capacity).clamp(0, 1),
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
              onTap: onToggleJoin,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                alignment: Alignment.center,
                child: Text(btnLabel, style: typography.headingSmall.copyWith(fontSize: 15, color: btnFg)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
