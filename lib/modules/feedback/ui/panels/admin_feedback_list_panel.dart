import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/admin_feedback_controller.dart';
import '../../domain/admin_feedback_entry.dart';

/// Admin 19 · Geri Bildirimler — üye feedback'lerinin listesi.
class AdminFeedbackListPanel extends BasePanel {
  const AdminFeedbackListPanel({super.key});

  @override
  ConsumerState<AdminFeedbackListPanel> createState() => _AdminFeedbackListPanelState();
}

class _AdminFeedbackListPanelState extends BasePanelState<AdminFeedbackListPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final summary = ref.watch(adminFeedbackControllerProvider);

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
                  Expanded(child: Text('Geri bildirimler', style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 24))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(summary.average.toStringAsFixed(1).replaceAll('.', ','), style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 38)),
                              Text(
                                '${summary.totalCount} değerlendirme',
                                style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            children: [
                              for (var star = 5; star >= 1; star--) _RatingBar(star: star, count: summary.starCounts[star] ?? 0, total: summary.totalCount),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final entry in summary.entries) _FeedbackCard(entry: entry),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.star, required this.count, required this.total});

  final int star;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final ratio = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 10, child: Text('$star', style: typography.headingSmall.copyWith(fontSize: 11, color: colors.onSurfaceMuted))),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(value: ratio, minHeight: 6, backgroundColor: colors.surfaceRaised, valueColor: AlwaysStoppedAnimation(colors.primary)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 20, child: Text('$count', textAlign: TextAlign.right, style: typography.headingSmall.copyWith(fontSize: 11, color: colors.onSurfaceMuted))),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.entry});

  final AdminFeedbackEntry entry;

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
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(entry.initials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 14)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.memberName, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
                    Text(entry.meta, style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.only(left: 3),
                      child: Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(color: i < entry.stars ? colors.primary : colors.surfaceRaised, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(entry.comment, style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
