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
import '../../controller/discover_controller.dart';
import '../../domain/discover_item.dart';

const _weekdayNames = {
  1: 'Pazartesi',
  2: 'Salı',
  3: 'Çarşamba',
  4: 'Perşembe',
  5: 'Cuma',
  6: 'Cumartesi',
  7: 'Pazar',
};

/// Üye 5 · Grup Dersi Detayı — [DiscoverPanel]'deki listeden bir grup dersi
/// kartına dokunulunca açılır. Admin'in oluştururken girdiği TÜM bilgileri
/// gösterir; katılım [DiscoverController.toggleJoin] üzerinden aynı ortak
/// mantığı (kontenjan kontrolü, kilit vb.) kullanır — kendi ayrı bir
/// katılım/kontenjan mantığı yok.
class GroupSessionDetailPanel extends BasePanel {
  const GroupSessionDetailPanel({super.key, required this.groupSessionId});

  final String groupSessionId;

  @override
  ConsumerState<GroupSessionDetailPanel> createState() =>
      _GroupSessionDetailPanelState();
}

class _GroupSessionDetailPanelState
    extends BasePanelState<GroupSessionDetailPanel> {
  bool _isJoining = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final items = ref.watch(discoverControllerProvider);
    final item = items.where((i) => i.id == widget.groupSessionId).firstOrNull;
    // Antrenörler sadece görüntüler — katılım/vazgeçme akışı yok, en alttaki
    // buton hiç gösterilmez.
    final isTrainer =
        ref.watch(currentRoleProvider).valueOrNull == AppRole.trainer;

    return Scaffold(
      body: SafeArea(
        child: item == null
            ? _NotFoundBody(onBack: () => _pop(ref))
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
                                RemoteConfigKeys.groupSessionsDetailTitle,
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
                                    RemoteConfigKeys.eventsDateFieldLabel,
                                  ),
                                ),
                                value:
                                    '${_weekdayNames[item.startTime!.weekday]}, ${item.day} ${item.month}',
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsStartTimeFieldLabel,
                                  ),
                                ),
                                value:
                                    '${item.startTime!.hour.toString().padLeft(2, '0')}:${item.startTime!.minute.toString().padLeft(2, '0')}',
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsDurationFieldLabel,
                                  ),
                                ),
                                value: ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .groupSessionsDurationSuffix,
                                      ),
                                    )
                                    .replaceAll(
                                      '{minutes}',
                                      '${item.durationMinutes ?? 0}',
                                    ),
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsTrainerFieldLabel,
                                  ),
                                ),
                                value: item.trainerNames.isEmpty
                                    ? '—'
                                    : item.trainerNames.join(', '),
                              ),
                              _DetailRow(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsCapacityFieldLabel,
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
                              ),
                              if ((item.location ?? '').isNotEmpty)
                                _DetailRow(
                                  label: ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .groupSessionsDefaultLocationLabel,
                                    ),
                                  ),
                                  value: item.location!,
                                  isLast: item.description.isEmpty,
                                ),
                              if (item.description.isNotEmpty)
                                _DetailRow(
                                  label: ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .groupSessionsDescriptionFieldLabel,
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
                                  RemoteConfigKeys
                                      .groupSessionsJoinedLeaveButton,
                                ),
                              )
                            : ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.groupSessionsJoinButton,
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

class _NotFoundBody extends StatelessWidget {
  const _NotFoundBody({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [AppBackButton(onTap: onBack)],
      ),
    );
  }
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
