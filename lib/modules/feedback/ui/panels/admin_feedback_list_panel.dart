import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/admin_feedback_controller.dart';
import '../../domain/admin_feedback_entry.dart';

/// Admin 19 · Geri Bildirimler — üye feedback'lerinin listesi.
class AdminFeedbackListPanel extends BasePanel {
  const AdminFeedbackListPanel({super.key});

  @override
  ConsumerState<AdminFeedbackListPanel> createState() =>
      _AdminFeedbackListPanelState();
}

class _AdminFeedbackListPanelState
    extends BasePanelState<AdminFeedbackListPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final summary = ref.watch(adminFeedbackControllerProvider);
    final entries = ref.watch(adminFeedbackFilteredEntriesProvider);
    final starFilter = ref.watch(adminFeedbackStarFilterProvider);
    final month = ref.watch(adminFeedbackSelectedMonthProvider);
    // Sınır kontrolü şart: Remote Config hazır değilse (ör. Firebase
    // başlatılmamış test ortamı) `rcTextProvider` boş string döner ve
    // `''.split(',')` TEK elemanlı bir liste verir — doğrudan
    // `[month - 1]` indekslemek RangeError ile paneli çökertiyordu.
    // `create_event_panel.dart`'taki `_formatDate` ile aynı desen.
    final monthNames = ref
        .watch(rcTextProvider(RemoteConfigKeys.commonMonthNamesLong))
        .split(',');
    final monthName = month.month >= 1 && month.month <= monthNames.length
        ? monthNames[month.month - 1].trim()
        : '';
    final monthLabel = monthName.isEmpty
        ? '${month.month}.${month.year}'
        : '$monthName ${month.year}';

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
                        rcTextProvider(RemoteConfigKeys.feedbackAdminListTitle),
                      ),
                      style: typography.headingLarge.copyWith(
                        color: colors.onSurface,
                        fontSize: 24,
                      ),
                    ),
                  ),
                  // Ay geçişi — liste tek bir ayla sınırlı olduğu için
                  // geçmiş ayların geri bildirimleri buradan görülüyor.
                  _MonthArrow(
                    icon: Icons.chevron_left,
                    onTap: () => ref
                        .read(adminFeedbackSelectedMonthProvider.notifier)
                        .previous(),
                  ),
                  Text(
                    monthLabel,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  _MonthArrow(
                    icon: Icons.chevron_right,
                    onTap: ref.watch(adminFeedbackCanGoNextMonthProvider)
                        ? () => ref
                              .read(adminFeedbackSelectedMonthProvider.notifier)
                              .next()
                        : null,
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 84,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                summary.average
                                    .toStringAsFixed(1)
                                    .replaceAll('.', ','),
                                style: typography.dataLarge.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 38,
                                ),
                              ),
                              Text(
                                ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .feedbackTotalReviewsCaption,
                                      ),
                                    )
                                    .replaceAll(
                                      '{count}',
                                      '${summary.totalCount}',
                                    ),
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            children: [
                              for (var star = 5; star >= 1; star--)
                                _RatingBar(
                                  star: star,
                                  count: summary.starCounts[star] ?? 0,
                                  total: summary.totalCount,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Yıldıza göre filtre — sorgu zaten tek bir ayla sınırlı
                  // olduğu için client tarafında uygulanıyor (ek index yok,
                  // geçiş anında). Aynı yıldıza tekrar dokunmak filtreyi
                  // kaldırır.
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _StarFilterChip(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.feedbackFilterAllLabel,
                            ),
                          ),
                          selected: starFilter == null,
                          onTap: () => ref
                              .read(adminFeedbackStarFilterProvider.notifier)
                              .clear(),
                        ),
                        for (var star = 5; star >= 1; star--)
                          _StarFilterChip(
                            label: '$star ★',
                            selected: starFilter == star,
                            count: summary.starCounts[star] ?? 0,
                            onTap: () => ref
                                .read(adminFeedbackStarFilterProvider.notifier)
                                .toggle(star),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (entries.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl,
                      ),
                      child: Text(
                        ref.watch(
                          rcTextProvider(
                            starFilter == null
                                ? RemoteConfigKeys.feedbackEmptyMonthLabel
                                : RemoteConfigKeys.feedbackEmptyFilterLabel,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    )
                  else
                    for (final entry in entries) _FeedbackCard(entry: entry),
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
  const _RatingBar({
    required this.star,
    required this.count,
    required this.total,
  });

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
          SizedBox(
            width: 10,
            child: Text(
              '$star',
              style: typography.headingSmall.copyWith(
                fontSize: 11,
                color: colors.onSurfaceMuted,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 6,
                backgroundColor: colors.surfaceRaised,
                valueColor: AlwaysStoppedAnimation(colors.primary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 20,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: typography.headingSmall.copyWith(
                fontSize: 11,
                color: colors.onSurfaceMuted,
              ),
            ),
          ),
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
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.initials,
                  style: typography.headingSmall.copyWith(
                    color: colors.onPrimaryContainer,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.memberName,
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      entry.meta,
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
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
                          decoration: BoxDecoration(
                            color: i < entry.stars
                                ? colors.primary
                                : colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            entry.comment,
            style: typography.bodyLarge.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ay geçiş oku — [onTap] `null` ise pasif görünür (içinde bulunulan
/// aydayken "sonraki" oku).
class _MonthArrow extends StatelessWidget {
  const _MonthArrow({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? colors.outlineStrong : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Yıldız filtresi çipi. [count] verilirse etiketin yanında o puandaki
/// geri bildirim sayısı gösterilir — admin hangi puanda kaç kayıt olduğunu
/// filtreye dokunmadan görebilsin diye.
class _StarFilterChip extends StatelessWidget {
  const _StarFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Material(
        color: selected ? colors.primary : colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: selected ? colors.primary : colors.outlineStrong,
              ),
            ),
            child: Text(
              count == null ? label : '$label ($count)',
              style: typography.headingSmall.copyWith(
                fontSize: 13,
                color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
