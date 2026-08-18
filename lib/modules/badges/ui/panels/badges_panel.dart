import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/badges_controller.dart';
import '../../domain/badge_item.dart';

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
    final badges = ref.watch(badgesControllerProvider);
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
                    'Rozetlerim',
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
                      'Rozetler yüklenemedi.',
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
                                    '$earnedCount rozet kazandın',
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (nextLocked != null)
                                    Text(
                                      'Sıradaki: ${nextLocked.note}',
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
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: badges.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisExtent: 118,
                        ),
                    itemBuilder: (context, index) =>
                        _BadgeTile(badge: badges[index]),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: badge.earned
                  ? colors.primaryContainer
                  : colors.surfaceRaised,
              shape: BoxShape.circle,
              border: Border.all(
                color: badge.earned ? colors.primary : colors.outlineStrong,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              badge.earned ? Icons.emoji_events : Icons.lock_outline,
              size: 18,
              color: badge.earned ? colors.primary : colors.onSurfaceMuted,
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
