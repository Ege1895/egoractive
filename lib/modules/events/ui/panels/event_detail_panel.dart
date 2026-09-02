import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../group_sessions/controller/discover_controller.dart';
import '../../../group_sessions/domain/discover_item.dart';
import '../../../../shared/utils/date_labels.dart';

/// Üye 5 · Etkinlik Detayı — [DiscoverPanel]'deki listeden bir etkinlik
/// kartına dokunulunca açılır. `group_session_detail_panel.dart` ile aynı
/// desen: katılım [DiscoverController.toggleJoin] üzerinden, kendi ayrı bir
/// kontenjan mantığı yok.
///
/// UX güncellemesi — [GroupSessionDetailPanel] ile aynı görsel dil: kontenjan
/// durumu liste kartlarındaki doluluk çubuğu + renk kodlamasıyla kendi
/// kartında öne çıkarılıyor, bilgi satırları ikonlu, açıklama kendi
/// kartında. İki detay ekranı artık tutarlı bir çift.
class EventDetailPanel extends BasePanel {
  const EventDetailPanel({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<EventDetailPanel> createState() => _EventDetailPanelState();
}

class _EventDetailPanelState extends BasePanelState<EventDetailPanel> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final items = ref.watch(discoverControllerProvider);
    final item = items.where((i) => i.id == widget.eventId).firstOrNull;
    // Antrenörler sadece görüntüler — katılım/vazgeçme akışı yok, en alttaki
    // buton hiç gösterilmez.
    final isTrainer =
        ref.watch(currentRoleProvider).valueOrNull == AppRole.trainer;

    return Scaffold(
      body: SafeArea(
        child: item == null
            ? Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppBackButton(onTap: () => _pop(ref)),
              )
            : Column(
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
                        AppBackButton(onTap: () => _pop(ref)),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.eventsDetailTitle,
                              ),
                            ),
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 18,
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
                        AppSpacing.lg,
                        AppSpacing.screenEdge,
                        AppSpacing.lg,
                      ),
                      children: [
                        Text(
                          item.title,
                          style: typography.headingLarge.copyWith(
                            color: colors.onSurface,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _CapacityCard(
                          ref: ref,
                          taken: item.taken,
                          capacity: item.capacity,
                          capacityLabel: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.eventsCapacityLabel,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusCard,
                            ),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Column(
                            children: [
                              _IconDetailRow(
                                icon: Icons.calendar_today_rounded,
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsDateFieldLabel,
                                  ),
                                ),
                                value: ref
                                    .watch(dateLabelsProvider)
                                    .weekdayWithDate(
                                      item.startTime!.weekday,
                                      '${item.day} ${item.month}',
                                    ),
                              ),
                              _IconDetailRow(
                                icon: Icons.access_time_rounded,
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsTimeFieldLabel,
                                  ),
                                ),
                                value:
                                    '${item.startTime!.hour.toString().padLeft(2, '0')}:${item.startTime!.minute.toString().padLeft(2, '0')}',
                              ),
                              _IconDetailRow(
                                icon: Icons.place_rounded,
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsLocationFieldLabel,
                                  ),
                                ),
                                value: item.location?.isNotEmpty == true
                                    ? item.location!
                                    : '—',
                                isLast: true,
                              ),
                            ],
                          ),
                        ),
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _DescriptionCard(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.eventsDescriptionFieldLabel,
                              ),
                            ),
                            text: item.description,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!isTrainer)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenEdge,
                        AppSpacing.md,
                        AppSpacing.screenEdge,
                        AppSpacing.lg,
                      ),
                      child: AppButton(
                        label: _isJoining
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersSavingLabel,
                                ),
                              )
                            : item.joined
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.eventsJoinedLeaveButton,
                                ),
                              )
                            : ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.eventsJoinButton,
                                ),
                              ),
                        onPressed:
                            _isJoining ||
                                (item.isFull && !item.joined) ||
                                (item.joined && !item.canLeave)
                            ? null
                            : () => _toggleJoin(item),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _toggleJoin(DiscoverItem item) async {
    setState(() => _isJoining = true);
    try {
      await ref.read(discoverControllerProvider.notifier).toggleJoin(item.id);
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError && error.message == 'Kontenjan doldu.'
          ? ref.read(
              rcTextProvider(
                RemoteConfigKeys.groupSessionsJoinFullErrorSnackbar,
              ),
            )
          : ref.read(
              rcTextProvider(RemoteConfigKeys.groupSessionsJoinFailedSnackbar),
            );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  void _pop(WidgetRef ref) =>
      ref.read(panelStackControllerProvider.notifier).pop();
}

/// Kontenjan durumunu liste kartlarıyla BİREBİR aynı renk mantığıyla (dolu →
/// kırmızı, son birkaç yer → sarı, uygun → primary) öne çıkaran kart — bkz.
/// `group_session_detail_panel.dart`'taki eşleniği.
class _CapacityCard extends StatelessWidget {
  const _CapacityCard({
    required this.ref,
    required this.taken,
    required this.capacity,
    required this.capacityLabel,
  });

  final WidgetRef ref;
  final int taken;
  final int? capacity;
  final String capacityLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final remaining = capacity == null ? null : capacity! - taken;
    final isFull = capacity != null && taken >= capacity!;
    final ratio = capacity == null ? 0.0 : taken / capacity!;

    final Color capFg;
    final Color barColor;
    final String note;
    if (isFull) {
      capFg = colors.error;
      barColor = colors.error;
      note = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsCapacityFullNote),
      );
    } else if (remaining != null && remaining <= 2) {
      capFg = colors.onWarningContainer;
      barColor = colors.warning;
      note = ref
          .watch(rcTextProvider(RemoteConfigKeys.groupSessionsCapacityLowNote))
          .replaceAll('{remaining}', '$remaining');
    } else {
      capFg = colors.onSurfaceVariant;
      barColor = colors.primary;
      note = ref.watch(
        rcTextProvider(RemoteConfigKeys.groupSessionsCapacityAvailableNote),
      );
    }

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  capacityLabel,
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ),
              Text(
                capacity == null ? '$taken' : '$taken/$capacity',
                style: typography.dataLarge.copyWith(
                  color: capFg,
                  fontSize: 26,
                ),
              ),
            ],
          ),
          if (capacity != null) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              child: LinearProgressIndicator(
                value: ratio.clamp(0, 1),
                minHeight: 8,
                backgroundColor: colors.surfaceRaised,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            note,
            style: typography.bodyMedium.copyWith(color: capFg, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Sol tarafta küçük bir ikon rozeti + sağda label/değer — bkz.
/// `group_session_detail_panel.dart`'taki eşleniği.
class _IconDetailRow extends StatelessWidget {
  const _IconDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.outline)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: typography.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Açıklama serbest metindir — bkz. `group_session_detail_panel.dart`'taki
/// eşleniği.
class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: typography.bodyLarge.copyWith(
              color: colors.onSurface,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
