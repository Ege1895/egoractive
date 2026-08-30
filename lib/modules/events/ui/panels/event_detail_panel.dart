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

const _weekdayNames = {
  1: 'Pazartesi',
  2: 'Salı',
  3: 'Çarşamba',
  4: 'Perşembe',
  5: 'Cuma',
  6: 'Cumartesi',
  7: 'Pazar',
};

/// Üye 5 · Etkinlik Detayı — [DiscoverPanel]'deki listeden bir etkinlik
/// kartına dokunulunca açılır. `group_session_detail_panel.dart` ile aynı
/// desen: katılım [DiscoverController.toggleJoin] üzerinden, kendi ayrı bir
/// kontenjan mantığı yok.
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
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsLocationFieldLabel,
                                  ),
                                ),
                                value: item.location?.isNotEmpty == true
                                    ? item.location!
                                    : '—',
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsDateFieldLabel,
                                  ),
                                ),
                                value:
                                    '${_weekdayNames[item.startTime!.weekday]}, ${item.day} ${item.month}',
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsTimeFieldLabel,
                                  ),
                                ),
                                value:
                                    '${item.startTime!.hour.toString().padLeft(2, '0')}:${item.startTime!.minute.toString().padLeft(2, '0')}',
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCapacityLabel,
                                  ),
                                ),
                                value: item.capacity == null
                                    ? ref
                                          .watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .groupSessionsAttendingCountNoCapacity,
                                            ),
                                          )
                                          .replaceAll(
                                            '{taken}',
                                            '${item.taken}',
                                          )
                                    : ref
                                          .watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .groupSessionsAttendingCountWithCapacity,
                                            ),
                                          )
                                          .replaceAll(
                                            '{taken}',
                                            '${item.taken}',
                                          )
                                          .replaceAll(
                                            '{capacity}',
                                            '${item.capacity}',
                                          ),
                                isLast: item.description.isEmpty,
                              ),
                              if (item.description.isNotEmpty)
                                _DetailRow(
                                  label: ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .eventsDescriptionFieldLabel,
                                    ),
                                  ),
                                  value: item.description,
                                  isLast: true,
                                ),
                            ],
                          ),
                        ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: colors.outline)),
      ),
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
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
    );
  }
}
