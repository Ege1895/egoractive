import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../sessions/service/session_completion_service.dart';
import '../../../sessions/ui/widgets/create_session_sheet.dart';
import '../../controller/trainer_calendar_controller.dart';
import '../../domain/schedule_slot.dart';

const _monthNames = {
  1: 'Ocak',
  2: 'Şubat',
  3: 'Mart',
  4: 'Nisan',
  5: 'Mayıs',
  6: 'Haziran',
  7: 'Temmuz',
  8: 'Ağustos',
  9: 'Eylül',
  10: 'Ekim',
  11: 'Kasım',
  12: 'Aralık',
};
const _dayNames = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/// Antrenör 5 · Takvimim (Takvimim sekmesi kökü) — admin'in aylık
/// takvimiyle (bkz. admin_calendar_panel.dart) birebir aynı tasarım:
/// ay ızgarası + gün altında ajanda listesi, hafta/ay geçişi yok.
class TrainerCalendarPanel extends BasePanel {
  const TrainerCalendarPanel({this.focusSessionId, super.key});

  /// Push bildirimi ("Dersini onaylar mısın?") üzerinden açıldığında set
  /// edilir — panel bu seansın tarihini otomatik seçip "Dersi onayla"
  /// sheet'ini otomatik açar (bkz. `push_notification_service.dart`).
  final String? focusSessionId;

  @override
  ConsumerState<TrainerCalendarPanel> createState() =>
      _TrainerCalendarPanelState();
}

class _TrainerCalendarPanelState extends BasePanelState<TrainerCalendarPanel> {
  /// `focusSessionId` sheet'i bir kez otomatik açtıktan sonra (ya da hedef
  /// seans bulunamadığında) `true` olur — her rebuild'de sheet'in tekrar
  /// tekrar açılmasını engeller.
  bool _focusSessionHandled = false;

  @override
  void initState() {
    super.initState();
    final sessionId = widget.focusSessionId;
    if (sessionId == null) {
      _focusSessionHandled = true;
      return;
    }
    _selectFocusSessionDate(sessionId);
  }

  Future<void> _selectFocusSessionDate(String sessionId) async {
    final doc = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .get();
    if (!mounted) return;
    final startTime = (doc.data()?['startTime'] as Timestamp?)?.toDate();
    if (startTime == null) {
      setState(() => _focusSessionHandled = true);
      return;
    }
    ref.read(trainerCalendarControllerProvider.notifier).selectDate(startTime);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(trainerCalendarControllerProvider);
    final controller = ref.read(trainerCalendarControllerProvider.notifier);
    final month = DateTime(state.selectedDate.year, state.selectedDate.month);
    final firstWeekday = month.weekday;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingBlanks = firstWeekday - 1;
    final totalCells = ((leadingBlanks + daysInMonth) / 7).ceil() * 7;
    final selectedSlots =
        state.slotsByDayOfMonth[state.selectedDate.day] ??
        const <ScheduleSlot>[];

    if (!_focusSessionHandled && widget.focusSessionId != null) {
      final matches = selectedSlots.where(
        (slot) => slot.id == widget.focusSessionId,
      );
      if (matches.isNotEmpty) {
        _focusSessionHandled = true;
        final slot = matches.first;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showSlotDetail(context, slot);
        });
      }
    }

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.trainersCalendarTitle),
                    ),
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      onTap: () => showCreateSessionSheet(
                        context,
                        ref,
                        state.selectedDate,
                        lockedTrainerId: ref
                            .read(authStateProvider)
                            .valueOrNull
                            ?.uid,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.commonAddSeansButton,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            fontSize: 14,
                            color: colors.onPrimary,
                          ),
                        ),
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
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_monthNames[month.month]} ${month.year}',
                              style: typography.headingSmall.copyWith(
                                color: colors.onSurface,
                                fontSize: 17,
                              ),
                            ),
                            Row(
                              children: [
                                _ArrowButton(
                                  icon: Icons.chevron_left,
                                  onTap: () => controller.selectDate(
                                    DateTime(month.year, month.month - 1, 1),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _ArrowButton(
                                  icon: Icons.chevron_right,
                                  onTap: () => controller.selectDate(
                                    DateTime(month.year, month.month + 1, 1),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final name in _dayNames)
                              Expanded(
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: typography.caption.copyWith(
                                    color: colors.onSurfaceMuted,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: totalCells,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                              ),
                          itemBuilder: (context, index) {
                            final dayNum = index - leadingBlanks + 1;
                            if (dayNum < 1 || dayNum > daysInMonth) {
                              return const SizedBox.shrink();
                            }
                            final date = DateTime(
                              month.year,
                              month.month,
                              dayNum,
                            );
                            final isSelected =
                                date.day == state.selectedDate.day;
                            final sessionCount =
                                state.slotsByDayOfMonth[dayNum]?.length ?? 0;
                            final hasSessions = sessionCount > 0;
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => controller.selectDate(date),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primaryContainer
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.primary
                                        : Colors.transparent,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      if (hasSessions)
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: colors.primary,
                                              width: 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: colors.primary
                                                    .withValues(alpha: 0.55),
                                                blurRadius: 10,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      Text(
                                        '$dayNum',
                                        style: typography.headingSmall.copyWith(
                                          fontSize: 14,
                                          color: isSelected
                                              ? colors.onPrimaryContainer
                                              : colors.onSurface,
                                        ),
                                      ),
                                      if (hasSessions)
                                        Positioned(
                                          top: -6,
                                          right: -6,
                                          child: _CalendarBadge(
                                            count: sessionCount,
                                            color: colors.primary,
                                            onColor: colors.onPrimary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    '${state.selectedDate.day} ${_monthNames[state.selectedDate.month]}',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (selectedSlots.isEmpty)
                    Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.commonBuGundeSeansYok),
                      ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
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
                          for (var i = 0; i < selectedSlots.length; i++)
                            _AgendaRow(
                              slot: selectedSlots[i],
                              showDivider: i < selectedSlots.length - 1,
                              onTap:
                                  selectedSlots[i].state ==
                                          ScheduleSlotState.planned ||
                                      selectedSlots[i].state ==
                                          ScheduleSlotState.current
                                  ? () => _showSlotDetail(
                                      context,
                                      selectedSlots[i],
                                    )
                                  : null,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Antrenörün kendi seansı için "Dersi onayla" sheet'i — planned/current
  /// seanslarda soru + "Ders tamamlandı"/"Üye gelmedi" butonlarını,
  /// başlangıcının üzerinden 24 saat geçmiş bir seansta ise butonları
  /// devre dışı bırakıp "yönetici ile iletişime geç" notunu gösterir (bkz.
  /// `firestore.rules`'taki `withinCompletionWindow()` — aynı pencere orada
  /// da zorlanıyor, burası sadece kullanıcıya erken/anlaşılır geri bildirim
  /// için). Zaten tamamlanmış/iptal edilmiş/üye gelmedi işaretli bir seans
  /// artık ajanda listesinden hiç tıklanamadığı için (bkz. `_AgendaRow`)
  /// buraya normalde ulaşmaz — sadece push bildirimiyle (`focusSessionId`)
  /// açıldığında, sheet açılana kadar başka biri seansı değiştirmişse diye
  /// yine de salt-okunur bir geri dönüş sağlanıyor.
  void _showSlotDetail(BuildContext context, ScheduleSlot slot) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final isActionable =
        slot.state == ScheduleSlotState.planned ||
        slot.state == ScheduleSlotState.current;
    final isExpired =
        isActionable &&
        DateTime.now().isAfter(
          slot.startTime.add(const Duration(hours: 24)),
        );
    final markCompletedLabel = ref.read(
      rcTextProvider(RemoteConfigKeys.trainersCalendarMarkCompletedAction),
    );
    final noShowLabel = ref.read(
      rcTextProvider(RemoteConfigKeys.sessionsCompletionMemberNoShowOption),
    );
    final questionText = ref
        .read(rcTextProvider(RemoteConfigKeys.sessionsCompletionQuestion))
        .replaceAll('{time}', slot.time)
        .replaceAll('{name}', slot.name);
    final timeLimitNote = ref.read(
      rcTextProvider(RemoteConfigKeys.sessionsCompletionTimeLimitNote),
    );
    final expiredNote = ref.read(
      rcTextProvider(RemoteConfigKeys.sessionsCompletionExpiredNote),
    );
    final genericErrorText = ref.read(
      rcTextProvider(RemoteConfigKeys.sessionsCompletionConfirmError),
    );
    final submittingLabel = ref.read(
      rcTextProvider(RemoteConfigKeys.gymsGymSetupSubmittingLabel),
    );
    final closeLabel = ref.read(rcTextProvider(RemoteConfigKeys.commonKapat));

    var isSubmitting = false;
    String? errorMessage;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> handle(bool attended) async {
              // slot.memberId sadece gerçek Firestore verisinden geliyorsa
              // dolu (bkz. #114) — mock fallback'te boş kalıp yazmadan
              // sheet'i kapatan eski önizleme davranışına düşer.
              if (slot.memberId.isEmpty) {
                Navigator.of(sheetContext).pop();
                return;
              }
              setSheetState(() {
                isSubmitting = true;
                errorMessage = null;
              });
              try {
                final service = ref.read(sessionCompletionServiceProvider);
                if (attended) {
                  await service.markCompleted(
                    sessionId: slot.id,
                    memberId: slot.memberId,
                  );
                } else {
                  await service.markAbsent(
                    sessionId: slot.id,
                    memberId: slot.memberId,
                  );
                }
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              } catch (_) {
                setSheetState(() {
                  isSubmitting = false;
                  errorMessage = genericErrorText;
                });
              }
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isActionable)
                    Text(
                      questionText,
                      style: typography.headingMedium.copyWith(
                        color: colors.onSurface,
                        fontSize: 24,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                          ),
                          child: Text(
                            slot.time,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            slot.name,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (isActionable) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _initialsOf(slot.name),
                              style: typography.headingSmall.copyWith(
                                color: colors.onPrimaryContainer,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            slot.meta,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  if (!isActionable)
                    AppButton(
                      label: closeLabel,
                      variant: AppButtonVariant.secondary,
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: isSubmitting
                                ? submittingLabel
                                : markCompletedLabel,
                            onPressed: (isSubmitting || isExpired)
                                ? null
                                : () => handle(true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppButton(
                            label: noShowLabel,
                            variant: AppButtonVariant.secondary,
                            onPressed: (isSubmitting || isExpired)
                                ? null
                                : () => handle(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isExpired ? expiredNote : timeLimitNote,
                      textAlign: TextAlign.center,
                      style: typography.caption.copyWith(
                        color: isExpired
                            ? colors.error
                            : colors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

String _initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Icon(icon, color: colors.onSurfaceVariant, size: 18),
        ),
      ),
    );
  }
}

class _CalendarBadge extends StatelessWidget {
  const _CalendarBadge({
    required this.count,
    required this.color,
    required this.onColor,
  });

  final int count;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        '$count',
        style: context.appTypography.caption.copyWith(
          color: onColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// `onTap` `null` ise (tamamlanmış/üye gelmedi/iptal edilmiş bir seans)
/// satır tıklanamaz — sağdaki ok yerine seansın son durumunu gösteren bir
/// pil rozeti çizilir, ki tıklanamadığı görsel olarak da anlaşılsın.
class _AgendaRow extends ConsumerWidget {
  const _AgendaRow({
    required this.slot,
    required this.showDivider,
    required this.onTap,
  });

  final ScheduleSlot slot;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final statePill = _statePill(context, ref, slot.state);

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: colors.outline))
              : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Text(
                slot.time,
                style: typography.headingSmall.copyWith(
                  color: colors.onSurface,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.name,
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    slot.meta,
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (statePill != null)
              statePill
            else if (onTap != null)
              Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget? _statePill(
    BuildContext context,
    WidgetRef ref,
    ScheduleSlotState state,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (background, foreground, label) = switch (state) {
      ScheduleSlotState.completed => (
        colors.successContainer,
        colors.onSuccessContainer,
        ref.watch(rcTextProvider(RemoteConfigKeys.commonTamamlandi)),
      ),
      ScheduleSlotState.absent => (
        colors.warningContainer,
        colors.onWarningContainer,
        ref.watch(
          rcTextProvider(RemoteConfigKeys.sessionsCompletionMemberNoShowOption),
        ),
      ),
      ScheduleSlotState.cancelled => (
        colors.errorContainer,
        colors.onErrorContainer,
        ref.watch(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
      ),
      ScheduleSlotState.planned || ScheduleSlotState.current => (null, null, null),
    };
    if (label == null) return null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(color: foreground, fontSize: 11),
      ),
    );
  }
}
