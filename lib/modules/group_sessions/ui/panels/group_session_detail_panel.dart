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
import '../../../../shared/utils/date_labels.dart';

/// Üye 5 · Grup Dersi Detayı — [DiscoverPanel]'deki listeden bir grup dersi
/// kartına dokunulunca açılır. Admin'in oluştururken girdiği TÜM bilgileri
/// gösterir; katılım [DiscoverController.toggleJoin] üzerinden aynı ortak
/// mantığı (kontenjan kontrolü, kilit vb.) kullanır — kendi ayrı bir
/// katılım/kontenjan mantığı yok.
///
/// UX güncellemesi — kontenjan durumu artık liste kartlarındaki (bkz.
/// `admin_group_sessions_panel.dart`/`discover_panel.dart`) doluluk çubuğu +
/// renk kodlamasıyla BİREBİR aynı görsel dilde, kendi kartında öne çıkarılmış
/// durumda (önceden düz bir metin satırıydı, buraya gelince kayboluyordu).
/// Bilgi satırları ikonlu hale getirildi (taranabilirlik için). Antrenör
/// görünümünde (katıl/ayrıl butonu yok) altta ölü boşluk bırakmak yerine
/// içerik doğal olarak biter.
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
                        _CapacityCard(
                          ref: ref,
                          taken: item.taken,
                          capacity: item.capacity,
                          capacityLabel: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.groupSessionsCapacityFieldLabel,
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
                                    RemoteConfigKeys
                                        .groupSessionsStartTimeFieldLabel,
                                  ),
                                ),
                                value:
                                    '${item.startTime!.hour.toString().padLeft(2, '0')}:${item.startTime!.minute.toString().padLeft(2, '0')}',
                              ),
                              _IconDetailRow(
                                icon: Icons.hourglass_bottom_rounded,
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
                              _IconDetailRow(
                                icon: Icons.person_rounded,
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsTrainerFieldLabel,
                                  ),
                                ),
                                value: item.trainerNames.isEmpty
                                    ? '—'
                                    : item.trainerNames.join(', '),
                                isLast: (item.location ?? '').isEmpty,
                              ),
                              if ((item.location ?? '').isNotEmpty)
                                _IconDetailRow(
                                  icon: Icons.place_rounded,
                                  label: ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .groupSessionsDefaultLocationLabel,
                                    ),
                                  ),
                                  value: item.location!,
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
                                RemoteConfigKeys
                                    .groupSessionsDescriptionFieldLabel,
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

/// Kontenjan durumunu liste kartlarıyla (bkz. `admin_group_sessions_panel.dart`
/// / `discover_panel.dart`) BİREBİR aynı renk mantığıyla (dolu → kırmızı,
/// son birkaç yer → sarı, uygun → primary) öne çıkaran kart — detay
/// ekranında bu bilginin düz bir metin satırına gömülüp kaybolmasını önler.
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

/// Sol tarafta küçük bir ikon rozeti + sağda label/değer — düz metin
/// satırlarından daha taranabilir, kullanıcı gözü ikonla eşleştirerek
/// hızlıca ilgili satırı bulur.
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

/// Açıklama serbest metindir (uzun olabilir) — label/değer satırı yerine
/// kendi kartında, okunabilir bir gövde metni olarak gösterilir.
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
