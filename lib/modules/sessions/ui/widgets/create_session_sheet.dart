import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/past_datetime_gate.dart';
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

const _weekdayShort = {
  1: 'Pzt',
  2: 'Sal',
  3: 'Çar',
  4: 'Per',
  5: 'Cum',
  6: 'Cmt',
  7: 'Paz',
};

const _monthShort = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

/// Atlanan günleri bildirimde "3.9" gibi belirsiz bir formatla değil, hangi
/// gün olduğu tek bakışta anlaşılsın diye "3 Eyl Per" şeklinde gösterir.
String _formatSkippedDay(DateTime date) =>
    '${date.day} ${_monthShort[date.month]} ${_weekdayShort[date.weekday]}';

String _formatTimeOfDay(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

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
///
/// F7-x — [groupSessionIds] verilirse (takvimde tek slota indirgenmiş bir
/// düet dersi) tüm üye dokümanları birlikte, tek bir yeni saate ertelenir.
Future<void> showRescheduleSessionSheet(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
  required DateTime currentStart,
  List<String>? groupSessionIds,
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

  final newStartTime = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  if (isPastDatetimeCreationBlocked(ref, newStartTime)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(rcTextProvider(RemoteConfigKeys.commonPastDatetimeError)),
        ),
      ),
    );
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final ids = groupSessionIds;
    if (ids != null && ids.length > 1) {
      await ref
          .read(sessionsWriteServiceProvider)
          .rescheduleDuetSession(ids, newStartTime);
    } else {
      await ref
          .read(sessionsWriteServiceProvider)
          .rescheduleSession(sessionId, newStartTime);
    }
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
  bool _isDuet = false;
  AdminMemberSummary? _member;
  List<AdminMemberSummary> _duetMembers = [];
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

  /// Düet modda en az 2 üye seçilmiş olmalı; birebir modda tek üye yeter.
  bool get _hasValidMemberSelection =>
      _isDuet ? _duetMembers.length >= 2 : _member != null;

  /// "Tekrarla" seçicisinin izin verdiği üst sınır — düet'te grup, en az
  /// hakka sahip üyenin kotasından fazla tekrar edemez. Toplam
  /// `remainingSessions` (planlanmış + planlanmamış) DEĞİL, henüz takvime
  /// hiç girilmemiş `unplannedSessions` kullanılıyor — aksi halde zaten
  /// tamamı planlanmış bir üyeye yeni seans atanabilirmiş gibi görünürdü.
  int get _effectiveRemainingSessions {
    if (_isDuet) {
      if (_duetMembers.isEmpty) return 0;
      return _duetMembers
          .map((m) => m.unplannedSessions)
          .reduce((a, b) => a < b ? a : b);
    }
    return _member?.unplannedSessions ?? 0;
  }

  /// "3 Eyl Per (antrenör dolu)" gibi — her atlanan günün yanına GERÇEK
  /// sebebini yazar, hepsini tek bir "antrenör dolu" etiketine indirgemez.
  String _skippedDayEntry(DateTime date, String reasonKey) {
    final reason = ref.read(rcTextProvider(reasonKey));
    return '${_formatSkippedDay(date)} ($reason)';
  }

  void _setDuet(bool value) {
    if (_isDuet == value) return;
    setState(() {
      _isDuet = value;
      _member = null;
      _duetMembers = [];
      _repeatDates = [];
      _errorMessage = null;
    });
  }

  Future<void> _create() async {
    if (!await ensureSubscriptionAllowsWrite(context, ref)) return;
    final trainer = _resolveTrainer(ref.read(adminTrainersControllerProvider));
    if (trainer == null) return;
    if (_isDuet && _duetMembers.length < 2) {
      setState(() {
        _errorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.sessionsCreateDuetMinMembersError),
        );
      });
      return;
    }
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
    // geçer, biri çakışırsa diğerleri yine de oluşturulur. Her atlanan gün,
    // KENDİ gerçek sebebiyle birlikte kaydediliyor — önceden hepsi tek bir
    // "antrenör dolu" mesajına düşüyordu, geçmiş tarih ya da üyenin seans
    // hakkının bitmesi gibi antrenörle ilgisi olmayan sebepler de yanlışlıkla
    // "antrenör dolu" gösteriliyordu.
    final allDates = [_date, ..._repeatDates];
    final failedDays = <String>[];
    var anySucceeded = false;
    var ranOutOfSessions = false;
    var hasPastDatetime = false;
    var hasUnknownError = false;
    var hasTrainerConflict = false;
    for (final date in allDates) {
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        _time.hour,
        _time.minute,
      );
      if (isPastDatetimeCreationBlocked(ref, startTime)) {
        failedDays.add(
          _skippedDayEntry(
            date,
            RemoteConfigKeys.sessionsSkipReasonPastDatetime,
          ),
        );
        hasPastDatetime = true;
        continue;
      }
      try {
        final service = ref.read(sessionsWriteServiceProvider);
        if (_isDuet) {
          await service.createDuetSession(
            gymId: gymId,
            trainerId: trainer.id,
            trainerName: trainer.name,
            members: [
              for (final member in _duetMembers)
                (id: member.id, name: member.name),
            ],
            startTime: startTime,
          );
        } else {
          await service.createSession(
            gymId: gymId,
            trainerId: trainer.id,
            trainerName: trainer.name,
            memberId: _member!.id,
            memberName: _member!.name,
            startTime: startTime,
          );
        }
        anySucceeded = true;
      } on TrainerConflictException {
        failedDays.add(
          _skippedDayEntry(
            date,
            RemoteConfigKeys.sessionsSkipReasonTrainerBusy,
          ),
        );
        hasTrainerConflict = true;
      } on InsufficientSessionsException {
        // Bu tarihten itibaren üyenin hakkı bitti — döngünün devamı da
        // aynı sebeple başarısız olacak, o yüzden burada kesiliyor.
        failedDays.add(
          _skippedDayEntry(
            date,
            RemoteConfigKeys.sessionsSkipReasonInsufficientSessions,
          ),
        );
        ranOutOfSessions = true;
        break;
      } catch (error) {
        // Trainer çakışması/hak yetersizliği/geçmiş tarih DIŞINDA beklenmeyen
        // bir hata (ör. Firestore izin reddi) — önceden bu durum da
        // sessizce "antrenör dolu" mesajına düşüyordu, gerçek sebebi
        // gizliyordu. debugPrint ile en azından konsolda görünür kalıyor.
        debugPrint('Seans oluşturulamadı ($date): $error');
        failedDays.add(
          _skippedDayEntry(
            date,
            RemoteConfigKeys.sessionsSkipReasonUnknownError,
          ),
        );
        hasUnknownError = true;
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
                .replaceAll('{name}', trainer.name)
                .replaceAll('{time}', _formatTimeOfDay(_time))
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
      _errorMessage = ranOutOfSessions
          ? ref.read(
              rcTextProvider(
                RemoteConfigKeys.sessionsRepeatCalendarExhaustedError,
              ),
            )
          : hasPastDatetime
          ? ref.read(rcTextProvider(RemoteConfigKeys.commonPastDatetimeError))
          : hasTrainerConflict
          ? ref
                .read(
                  rcTextProvider(
                    RemoteConfigKeys.sessionsCreateTrainerBusyError,
                  ),
                )
                .replaceAll('{name}', trainer.name)
          : hasUnknownError
          ? ref.read(
              rcTextProvider(RemoteConfigKeys.sessionsCreateGenericError),
            )
          : ref
                .read(
                  rcTextProvider(
                    RemoteConfigKeys.sessionsCreateTrainerBusyError,
                  ),
                )
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
          Text(
            ref.watch(rcTextProvider(RemoteConfigKeys.sessionsCreateKindLabel)),
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SessionKindToggle(
            isDuet: _isDuet,
            individualLabel: ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsCreateKindIndividual),
            ),
            duetLabel: ref.watch(
              rcTextProvider(RemoteConfigKeys.sessionsCreateKindDuet),
            ),
            onChanged: _setDuet,
          ),
          const SizedBox(height: AppSpacing.lg),
          _PickerRow(
            label: ref.watch(
              rcTextProvider(
                _isDuet
                    ? RemoteConfigKeys.sessionsCreateMembersFieldLabel
                    : RemoteConfigKeys.shellRolePickerMemberButton,
              ),
            ),
            value: _isDuet
                ? (_duetMembers.isEmpty
                      ? ref.watch(
                          rcTextProvider(
                            RemoteConfigKeys.sessionsCreateSelectPlaceholder,
                          ),
                        )
                      : ref
                            .watch(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .sessionsCreateDuetMembersSummary,
                              ),
                            )
                            .replaceAll('{count}', '${_duetMembers.length}'))
                : (_member == null
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
                            .replaceAll(
                              '{count}',
                              '${_member!.unplannedSessions}',
                            )),
            onTap: _isDuet
                ? () => _pickMultipleFromList(
                    title: ref.read(
                      rcTextProvider(
                        RemoteConfigKeys.sessionsCreatePickMembersTitle,
                      ),
                    ),
                    items: members,
                    initiallySelected: _duetMembers,
                    labelOf: (m) => m.name,
                    subtitleOf: (m) => ref
                        .read(
                          rcTextProvider(
                            RemoteConfigKeys.sessionsCreateMemberSessionsSuffix,
                          ),
                        )
                        .replaceAll('{count}', '${m.unplannedSessions}'),
                    onConfirm: (selected) => setState(() {
                      _duetMembers = selected;
                      // Kalan seans sayısı üyeye özel — seçim değişince
                      // önceki tekrar günleri yeni kotayı yansıtmıyor olur.
                      _repeatDates = [];
                    }),
                  )
                : () => _pickFromList<AdminMemberSummary>(
                    title: ref.read(
                      rcTextProvider(
                        RemoteConfigKeys.sessionsCreatePickMemberTitle,
                      ),
                    ),
                    items: members,
                    labelOf: (m) => m.name,
                    subtitleOf: (m) => ref
                        .read(
                          rcTextProvider(
                            RemoteConfigKeys.sessionsCreateMemberSessionsSuffix,
                          ),
                        )
                        .replaceAll('{count}', '${m.unplannedSessions}'),
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
            onTap: !_hasValidMemberSelection
                ? null
                : () async {
                    final result = await showRepeatSessionCalendarSheet(
                      context,
                      baseDate: _date,
                      remainingSessions: _effectiveRemainingSessions,
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
            onPressed:
                !_hasValidMemberSelection || trainer == null || _isCreating
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

  /// Düet ders üye seçimi — [_pickFromList]'in çoklu seçim versiyonu.
  /// Onay verilene kadar sheet kapanmaz, her satır bir checkbox ile
  /// işaretlenip kaldırılabilir.
  void _pickMultipleFromList({
    required String title,
    required List<AdminMemberSummary> items,
    required List<AdminMemberSummary> initiallySelected,
    required String Function(AdminMemberSummary) labelOf,
    required void Function(List<AdminMemberSummary>) onConfirm,
    String Function(AdminMemberSummary)? subtitleOf,
  }) {
    final colors = context.appColors;
    final selected = [...initiallySelected];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
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
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final item in items)
                          InkWell(
                            onTap: () => setSheetState(() {
                              final index = selected.indexWhere(
                                (m) => m.id == item.id,
                              );
                              if (index >= 0) {
                                selected.removeAt(index);
                              } else {
                                selected.add(item);
                              }
                            }),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 52),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: selected.any((m) => m.id == item.id),
                                    onChanged: (_) => setSheetState(() {
                                      final index = selected.indexWhere(
                                        (m) => m.id == item.id,
                                      );
                                      if (index >= 0) {
                                        selected.removeAt(index);
                                      } else {
                                        selected.add(item);
                                      }
                                    }),
                                  ),
                                  Expanded(
                                    child: Text(
                                      labelOf(item),
                                      style: context.appTypography.bodyLarge
                                          .copyWith(
                                            color: colors.onSurface,
                                            fontSize: 15,
                                          ),
                                    ),
                                  ),
                                  if (subtitleOf != null)
                                    Text(
                                      subtitleOf(item),
                                      style: context.appTypography.caption
                                          .copyWith(
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
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: ref.read(
                    rcTextProvider(RemoteConfigKeys.commonTamamButton),
                  ),
                  onPressed: () {
                    onConfirm(selected);
                    Navigator.of(sheetContext).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SessionKindToggle extends StatelessWidget {
  const _SessionKindToggle({
    required this.isDuet,
    required this.individualLabel,
    required this.duetLabel,
    required this.onChanged,
  });

  final bool isDuet;
  final String individualLabel;
  final String duetLabel;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SessionKindSegment(
              label: individualLabel,
              selected: !isDuet,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _SessionKindSegment(
              label: duetLabel,
              selected: isDuet,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionKindSegment extends StatelessWidget {
  const _SessionKindSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Material(
      color: selected ? colors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner - 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner - 2),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 40),
          child: Text(
            label,
            style: typography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
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
