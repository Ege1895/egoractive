import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/badges_controller.dart';
import '../../domain/badge_item.dart';

/// Rozetlerin en kolaydan en zora doğru gösterim sırası (bkz.
/// docs/badge_icon_prompts.md'deki bronz→elmas kademelendirme) — RC'deki
/// `cfg_badge_criteria` dizisinin sırası bunu garanti etmiyor, bu yüzden
/// listelemeden önce burada tanımlanan sıraya göre yeniden diziliyor.
/// Kriterlerde olup burada olmayan bir id (yeni eklenmiş, henüz
/// sıralanmamış bir rozet) sona düşer.
const _badgeDisplayOrder = [
  'first_session',
  'feedback_given',
  'measurement_logged',
  'group_session_join',
  'event_join',
  'sessions_5',
  'sessions_20',
  'membership_6_months',
  'sessions_50',
  'membership_12_months',
];

List<BadgeItem> _sortedByDifficulty(List<BadgeItem> badges) {
  final sorted = [...badges];
  sorted.sort((a, b) {
    final aIndex = _badgeDisplayOrder.indexOf(a.id);
    final bIndex = _badgeDisplayOrder.indexOf(b.id);
    return (aIndex == -1 ? _badgeDisplayOrder.length : aIndex).compareTo(
      bIndex == -1 ? _badgeDisplayOrder.length : bIndex,
    );
  });
  return sorted;
}

/// Üye 6 · Rozetlerim — kazanılan + yolda olan.
class BadgesPanel extends BasePanel {
  const BadgesPanel({super.key});

  @override
  ConsumerState<BadgesPanel> createState() => _BadgesPanelState();
}

class _BadgesPanelState extends BasePanelState<BadgesPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final badges = _sortedByDifficulty(ref.watch(badgesControllerProvider));
    final hasError = ref.watch(badgesControllerProvider.notifier).hasError;
    final earnedCount = badges.where((b) => b.earned).length;
    final nextLocked = badges.isEmpty
        ? null
        : badges.firstWhere((b) => !b.earned, orElse: () => badges.last);

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
                  Text(
                    ref.watch(rcTextProvider(RemoteConfigKeys.badgesTitle)),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
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
                  if (hasError) ...[
                    Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.badgesLoadError),
                      ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ref
                                        .watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .badgesEarnedCountLabel,
                                          ),
                                        )
                                        .replaceAll('{count}', '$earnedCount'),
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (nextLocked != null)
                                    Text(
                                      ref
                                          .watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .badgesNextLockedLabel,
                                            ),
                                          )
                                          .replaceAll(
                                            '{note}',
                                            nextLocked.note,
                                          ),
                                      style: typography.bodyMedium.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text.rich(
                              TextSpan(
                                text: '$earnedCount',
                                style: typography.dataLarge.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontSize: 28,
                                ),
                                children: [
                                  TextSpan(
                                    text: '/${badges.length}',
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          child: LinearProgressIndicator(
                            value: badges.isEmpty
                                ? 0
                                : earnedCount / badges.length,
                            minHeight: 8,
                            backgroundColor: colors.surfaceRaised,
                            valueColor: AlwaysStoppedAnimation(colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const crossAxisCount = 3;
                      const spacing = AppSpacing.md;
                      final itemWidth =
                          (constraints.maxWidth -
                              spacing * (crossAxisCount - 1)) /
                          crossAxisCount;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        // 10 rozet 3'lü gridde son satırda tek başına kalıyor
                        // — WrapAlignment.center o satırdaki tek rozeti
                        // sol yaslı bırakmak yerine ekranın ortasına alıyor.
                        alignment: WrapAlignment.center,
                        children: [
                          for (final badge in badges)
                            SizedBox(
                              width: itemWidth,
                              height: 138,
                              child: _BadgeTile(badge: badge),
                            ),
                        ],
                      );
                    },
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

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});

  final BadgeItem badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: badge.earned ? colors.primaryContainer : colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(
          color: badge.earned
              ? colors.primary.withValues(alpha: 0.32)
              : colors.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            // Kullanıcının rozet ikonunu net görebilmesi için orijinal
            // 44'ün 1.3 katı.
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.earned ? colors.primary : colors.outlineStrong,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Opacity(
                // Kazanılmamış rozet kilit ikonu yerine SOLUK (düşük opaklık)
                // gösteriliyor — kazanılan canlı/tam opaklıkta.
                opacity: badge.earned ? 1 : 0.35,
                child: Image.asset(
                  'assets/badges/${badge.id}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: badge.earned
                        ? colors.primaryContainer
                        : colors.surfaceRaised,
                    alignment: Alignment.center,
                    child: Icon(
                      badge.earned ? Icons.emoji_events : Icons.lock_outline,
                      size: 23,
                      color: badge.earned
                          ? colors.primary
                          : colors.onSurfaceMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: typography.headingSmall.copyWith(
              fontSize: 12,
              color: badge.earned ? colors.onSurface : colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            badge.note,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
