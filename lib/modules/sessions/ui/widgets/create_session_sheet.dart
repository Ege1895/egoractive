import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../members/controller/admin_members_controller.dart';
import '../../../members/domain/admin_member_summary.dart';
import '../../../trainers/controller/admin_trainers_controller.dart';
import '../../../trainers/domain/admin_trainer_summary.dart';
import '../../service/sessions_write_service.dart';
import 'repeat_session_calendar_sheet.dart';

/// F3-3 — "+ Seans": üye + antrenör + tarih/saat seçip `sessions`
/// koleksiyonuna gerçek bir doküman yazar.
///
/// [lockedTrainerId] verilirse (antrenörün kendi ekranından açılışı) antrenör
/// seçim adımı gösterilmez, seans doğrudan o antrenöre atanır — bir antrenör
/// başka bir antrenöre seans atayamaz, sadece üye seçer.
Future<void> showCreateSessionSheet(
  BuildContext context,
  WidgetRef ref,
  DateTime initialDate, {
  String? lockedTrainerId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _CreateSessionSheet(
      initialDate: initialDate,
      lockedTrainerId: lockedTrainerId,
    ),
  );
}

/// F3-3 — "Seansı ertele": mevcut bir seansın `startTime`'ını değiştirir.
Future<void> showRescheduleSessionSheet(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
  required DateTime currentStart,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: currentStart,
    firstDate: DateTime.now().subtract(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(currentStart),
  );
  if (time == null || !context.mounted) return;

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    await ref
        .read(sessionsWriteServiceProvider)
        .rescheduleSession(
          sessionId,
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
  } on TrainerConflictException catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref
                .read(
                  rcTextProvider(
                    RemoteConfigKeys.sessionsCreateTrainerBusyError,
                  ),
                )
                .replaceAll('{name}', e.trainerName),
          ),
        ),
      );
    }
    return;
  } catch (_) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(
              rcTextProvider(RemoteConfigKeys.sessionsCreateRescheduleError),
            ),
          ),
        ),
      );
    }
    return;
  }
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
}

class _CreateSessionSheet extends ConsumerStatefulWidget {
  const _CreateSessionSheet({required this.initialDate, this.lockedTrainerId});

  final DateTime initialDate;
  final String? lockedTrainerId;

  @override
  ConsumerState<_CreateSessionSheet> createState() =>
      _CreateSessionSheetState();
}

class _CreateSessionSheetState extends ConsumerState<_CreateSessionSheet> {
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  AdminMemberSummary? _member;
  AdminTrainerSummary? _trainer;
  List<DateTime> _repeatDates = [];
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  /// [widget.lockedTrainerId] verilmişse (antrenörün kendi ekranı) seçim her
  /// zaman o antrenöre kilitlenir, [_trainer] hiç kullanılmaz.
  AdminTrainerSummary? _resolveTrainer(List<AdminTrainerSummary> trainers) {
    final lockedId = widget.lockedTrainerId;
    if (lockedId != null) {
      for (final trainer in trainers) {
        if (trainer.id == lockedId) return trainer;
      }
      return null;
    }
    return _trainer;
  }

  Future<void> _create() async {
    if (!await ensureSubscriptionAllowsWrite(context, ref)) return;
    final trainer = _resolveTrainer(ref.read(adminTrainersControllerProvider));
    if (trainer == null) return;
    setState(() {
      _isCreating = true;
      _errorMessage = null;
    });
    final gymId = await ref.read(activeGymIdProvider.future);
    if (gymId == null) {
      if (mounted) {
        setState(() {
          _isCreating = false;
          _errorMessage = ref.read(
            rcTextProvider(RemoteConfigKeys.sessionsCreateNoActiveGymError),
          );
        });
      }
      return;
    }

    // "Tekrarla"dan eklenen ek günler de aynı saatle, ana tarihle birlikte
    // ayrı ayrı oluşturulur — her biri kendi antrenör çakışma kontrolünden
    // geçer, biri çakışırsa diğerleri yine de oluşturulur.
    final allDates = [_date, ..._repeatDates];
    final failedDays = <String>[];
    var anySucceeded = false;
    for (final date in allDates) {
      try {
        await ref
            .read(sessionsWriteServiceProvider)
            .createSession(
              gymId: gymId,
              trainerId: trainer.id,
              trainerName: trainer.name,
              memberId: _member!.id,
              memberName: _member!.name,
              startTime: DateTime(
                date.year,
                date.month,
                date.day,
                _time.hour,
                _time.minute,
              ),
            );
        anySucceeded = true;
      } on TrainerConflictException {
        failedDays.add('${date.day}.${date.month}');
      } catch (_) {
        failedDays.add('${date.day}.${date.month}');
      }
    }

    if (!mounted) return;
    if (failedDays.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    if (anySucceeded) {
      // Ana işlem (en az bir seans) başarılı — sheet kapanır, hangi
      // günlerin çakışma yüzünden atlandığı bir SnackBar'la bildirilir
      // (sheet kapanınca inline hata mesajı görünmeden kaybolurdu).
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref
                .read(
                  rcTextProvider(
                    RemoteConfigKeys.sessionsCreateSkippedDaysSnackbar,
                  ),
                )
                .replaceAll('{days}', failedDays.join(', ')),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isCreating = false;
      _errorMessage = ref
          .read(rcTextProvider(RemoteConfigKeys.sessionsCreateTrainerBusyError))
          .replaceAll('{name}', trainer.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final members = ref.watch(adminMembersControllerProvider);
    final trainers = ref.watch(adminTrainersControllerProvider);
    final trainer = _resolveTrainer(trainers);
    final trainerLocked = widget.lockedTrainerId != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.watch(rcTextProvider(RemoteConfigKeys.sessionsCreateTitle)),
            style: typography.headingMedium.copyWith(
              color: colors.onSurface,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _PickerRow(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.shellRolePickerMemberButton),
            ),
            value: _member == null
                ? ref.watch(
                    rcTextProvider(
                      RemoteConfigKeys.sessionsCreateSelectPlaceholder,
                    ),
                  )
                : ref
                      .watch(
                        rcTextProvider(
                          RemoteConfigKeys.sessionsCreateMemberSummary,
                        ),
                      )
                      .replaceAll('{name}', _member!.name)
                      .replaceAll('{count}', '${_member!.remainingSessions}'),
            onTap: () => _pickFromList<AdminMemberSummary>(
              title: ref.read(
                rcTextProvider(RemoteConfigKeys.sessionsCreatePickMemberTitle),
              ),
              items: members,
              labelOf: (m) => m.name,
              subtitleOf: (m) => ref
                  .read(
                    rcTextProvider(
                      RemoteConfigKeys.sessionsCreateMemberSessionsSuffix,
                    ),
                  )
                  .replaceAll('{count}', '${m.remainingSessions}'),
              onSelected: (m) => setState(() {
                _member = m;
                // Kalan seans sayısı üyeye özel — üye değişince önceki
                // seçimler yeni üyenin kotasını hiç yansıtmıyor olur.
                _repeatDates = [];
              }),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.membersTrainerFieldLabel),
            ),
            value:
                trainer?.name ??
                (trainerLocked
                    ? '—'
                    : ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.sessionsCreateSelectPlaceholder,
                        ),
                      )),
            onTap: trainerLocked
                ? null
                : () => _pickFromList<AdminTrainerSummary>(
                    title: ref.read(
                      rcTextProvider(
                        RemoteConfigKeys.sessionsCreatePickTrainerTitle,
                      ),
                    ),
                    items: trainers,
                    labelOf: (t) => t.name,
                    onSelected: (t) => setState(() => _trainer = t),
                  ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.eventsDateFieldLabel),
            ),
            value: '${_date.day}.${_date.month}.${_date.year}',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _date = picked;
                  _repeatDates = [];
                });
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsCalendarSlotTimeLabel),
            ),
            value: _time.format(context),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsCreateRepeatLabel),
            ),
            value: _repeatDates.isEmpty
                ? ref.watch(
                    rcTextProvider(
                      RemoteConfigKeys.sessionsCreateSelectPlaceholder,
                    ),
                  )
                : ref
                      .watch(
                        rcTextProvider(
                          RemoteConfigKeys.sessionsCreateRepeatDaysSelected,
                        ),
                      )
                      .replaceAll('{count}', '${_repeatDates.length}'),
            onTap: _member == null
                ? null
                : () async {
                    final result = await showRepeatSessionCalendarSheet(
                      context,
                      baseDate: _date,
                      remainingSessions: _member!.remainingSessions,
                      initiallySelected: _repeatDates,
                    );
                    if (result != null) {
                      setState(() => _repeatDates = result);
                    }
                  },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: typography.bodyMedium.copyWith(
                color: colors.error,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          AppButton(
            label: _isCreating
                ? ref.watch(
                    rcTextProvider(
                      RemoteConfigKeys.gymsGymSetupSubmittingLabel,
                    ),
                  )
                : ref.watch(
                    rcTextProvider(RemoteConfigKeys.sessionsCreateSubmitButton),
                  ),
            onPressed: _member == null || trainer == null || _isCreating
                ? null
                : _create,
          ),
        ],
      ),
    );
  }

  void _pickFromList<T>({
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
    required void Function(T) onSelected,
    String Function(T)? subtitleOf,
  }) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.appTypography.headingMedium.copyWith(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final item in items)
                InkWell(
                  onTap: () {
                    onSelected(item);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            labelOf(item),
                            style: context.appTypography.bodyLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (subtitleOf != null)
                          Text(
                            subtitleOf(item),
                            style: context.appTypography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final disabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: typography.bodyLarge.copyWith(
                  color: disabled
                      ? colors.onSurfaceMuted
                      : colors.onSurfaceVariant,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              value,
              style: typography.headingSmall.copyWith(
                color: disabled ? colors.onSurfaceMuted : colors.onSurface,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
