import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../../trainers/controller/admin_trainers_controller.dart';
import '../../controller/create_group_session_controller.dart';
import '../../domain/create_group_session_form.dart';
import '../widgets/repeat_group_session_calendar_sheet.dart';

/// Antrenör 7 · Grup Dersi Oluştur — kontenjan ve gün seçimi. [groupSessionId]
/// verilirse düzenleme moduna geçer: mevcut ders yüklenir, "Tekrarla" kalkar,
/// en altta "İptal Et" görünür (bkz. `_isEditing`).
class CreateGroupSessionPanel extends BasePanel {
  const CreateGroupSessionPanel({super.key, this.groupSessionId});

  final String? groupSessionId;

  @override
  ConsumerState<CreateGroupSessionPanel> createState() =>
      _CreateGroupSessionPanelState();
}

class _CreateGroupSessionPanelState
    extends BasePanelState<CreateGroupSessionPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _studioNameController;
  late final TextEditingController _descriptionController;
  final _descriptionScrollController = ScrollController();
  bool _hydratedForEdit = false;

  bool get _isEditing => widget.groupSessionId != null;

  @override
  void initState() {
    super.initState();
    // Önceki sürümde bu alanın `controller` parametresi hiç verilmemişti —
    // TextField kendi iç state'ini tutuyordu, provider'daki `form.title` ile
    // senkron değildi (ör. panel yeniden build olunca alan sıfırlanabilirdi).
    _titleController = TextEditingController();
    _studioNameController = TextEditingController();
    _descriptionController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(
        createGroupSessionControllerProvider.notifier,
      );
      final id = widget.groupSessionId;
      if (id != null) {
        controller.loadForEdit(id);
      } else {
        controller.resetForCreate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final form = ref.watch(createGroupSessionControllerProvider);
    final controller = ref.read(createGroupSessionControllerProvider.notifier);
    final panelStack = ref.read(panelStackControllerProvider.notifier);

    // `resetForCreate()`/`loadForEdit()` postFrame'de çalışıyor (initState
    // senkron değil) — gerçek veri geldiğinde text controller'lar BİR KEZ
    // dolduruluyor, sonrasında kullanıcı yazarken üzerine yazılmıyor.
    final readyForHydration = _isEditing
        ? form.editingId == widget.groupSessionId
        : form.editingId == null && !form.isLoadingForEdit;
    if (!_hydratedForEdit && readyForHydration) {
      _hydratedForEdit = true;
      _titleController.text = form.title;
      _studioNameController.text = form.studioName;
      _descriptionController.text = form.description;
    }

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
                  Expanded(
                    child: Text(
                      ref.watch(
                        rcTextProvider(
                          _isEditing
                              ? RemoteConfigKeys.groupSessionsEditTitle
                              : RemoteConfigKeys.groupSessionsCreateTitle,
                        ),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => panelStack.pop(),
                    child: Text(
                      ref.watch(rcTextProvider(RemoteConfigKeys.commonVazgec)),
                      style: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 15,
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
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.groupSessionsNameFieldLabel,
                            ),
                          ),
                          controller: _titleController,
                          errorText: form.titleError,
                          onChanged: controller.setTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsStartTimeFieldLabel,
                                  ),
                                ),
                                value: form.startTime,
                                onTap: () =>
                                    _pickStartTime(context, controller, form),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _InfoField(
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
                                      '${form.durationMinutes}',
                                    ),
                                onTap: () => _pickDuration(
                                  context,
                                  controller,
                                  form.durationMinutes,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _InfoField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsDateFieldLabel,
                                  ),
                                ),
                                value: form.selectedDate == null
                                    ? ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys.eventsDateFieldHint,
                                        ),
                                      )
                                    : _formatDate(ref, form.selectedDate!),
                                onTap: () => showNativeDatePicker(
                                  context: context,
                                  initial: form.selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                  onSelected: controller.setSelectedDate,
                                ),
                              ),
                            ),
                            if (!_isEditing) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _InfoField(
                                  label: ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .sessionsCreateRepeatLabel,
                                    ),
                                  ),
                                  value: form.repeatDates.isEmpty
                                      ? ref.watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .sessionsCreateSelectPlaceholder,
                                          ),
                                        )
                                      : ref
                                            .watch(
                                              rcTextProvider(
                                                RemoteConfigKeys
                                                    .sessionsCreateRepeatDaysSelected,
                                              ),
                                            )
                                            .replaceAll(
                                              '{count}',
                                              '${form.repeatDates.length}',
                                            ),
                                  onTap: form.selectedDate == null
                                      ? null
                                      : () async {
                                          final result =
                                              await showRepeatGroupSessionCalendarSheet(
                                                context,
                                                baseDate: form.selectedDate!,
                                                initiallySelected:
                                                    form.repeatDates,
                                              );
                                          if (result != null) {
                                            controller.setRepeatDates(result);
                                          }
                                        },
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (form.dateError != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            form.dateError!,
                            style: typography.bodyMedium.copyWith(
                              color: colors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        _InfoField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.groupSessionsTrainerFieldLabel,
                            ),
                          ),
                          value: form.trainerIds.isEmpty
                              ? ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsTrainerFieldPlaceholder,
                                  ),
                                )
                              : ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .groupSessionsTrainerCountSelected,
                                      ),
                                    )
                                    .replaceAll(
                                      '{count}',
                                      '${form.trainerIds.length}',
                                    ),
                          onTap: () =>
                              _pickTrainers(context, ref, controller, form),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Scrollbar(
                          controller: _descriptionScrollController,
                          thumbVisibility: true,
                          interactive: true,
                          thickness: 4,
                          radius: const Radius.circular(4),
                          child: AppTextField(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .groupSessionsDescriptionFieldLabel,
                              ),
                            ),
                            controller: _descriptionController,
                            scrollController: _descriptionScrollController,
                            minLines: 1,
                            maxLines: 5,
                            onChanged: controller.setDescription,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .groupSessionsDescriptionCharCountTemplate,
                                  ),
                                )
                                .replaceAll(
                                  '{count}',
                                  '${form.description.length}',
                                )
                                .replaceAll(
                                  '{max}',
                                  '${form.descriptionMaxChars}',
                                ),
                            style: typography.caption.copyWith(
                              color: controller.isDescriptionOverLimit
                                  ? colors.error
                                  : colors.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .groupSessionsCapacityFieldLabel,
                                      ),
                                    ),
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    form.studioName.trim().isEmpty
                                        ? ref
                                              .watch(
                                                rcTextProvider(
                                                  RemoteConfigKeys
                                                      .groupSessionsCapacityMaxNote,
                                                ),
                                              )
                                              .replaceAll(
                                                '{max}',
                                                '${form.capacityMax}',
                                              )
                                        : ref
                                              .watch(
                                                rcTextProvider(
                                                  RemoteConfigKeys
                                                      .groupSessionsCapacityMaxNoteWithStudio,
                                                ),
                                              )
                                              .replaceAll(
                                                '{studio}',
                                                form.studioName,
                                              )
                                              .replaceAll(
                                                '{max}',
                                                '${form.capacityMax}',
                                              ),
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StepperButton(
                              icon: Icons.remove,
                              onTap: controller.decrementCapacity,
                              filled: false,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${form.capacity}',
                                textAlign: TextAlign.center,
                                style: typography.headingMedium.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            _StepperButton(
                              icon: Icons.add,
                              onTap: controller.incrementCapacity,
                              filled: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          child: LinearProgressIndicator(
                            value: (form.capacity / form.capacityMax).clamp(
                              0,
                              1,
                            ),
                            minHeight: 6,
                            backgroundColor: colors.surfaceRaised,
                            valueColor: AlwaysStoppedAnimation(colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
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
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colors.outline),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .groupSessionsOnlineBookingToggleLabel,
                                        ),
                                      ),
                                      style: typography.bodyLarge.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .groupSessionsOnlineBookingToggleDescription,
                                        ),
                                      ),
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.toggleOnlineBooking,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 52,
                                  height: 32,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: form.onlineBookingEnabled
                                        ? colors.primary
                                        : colors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  alignment: form.onlineBookingEnabled
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: colors.onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .groupSessionsDefaultLocationLabel,
                            ),
                          ),
                          hint: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.groupSessionsLocationFieldHint,
                            ),
                          ),
                          controller: _studioNameController,
                          onChanged: controller.setStudioName,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.groupSessionsLocationFieldHelper,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (form.errorMessage != null) ...[
                    Text(
                      form.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: form.isSubmitting
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymSetupSubmittingLabel,
                            ),
                          )
                        : ref.watch(
                            rcTextProvider(
                              _isEditing
                                  ? RemoteConfigKeys
                                        .groupSessionsEditSubmitButton
                                  : RemoteConfigKeys
                                        .groupSessionsCreateSubmitButton,
                            ),
                          ),
                    onPressed:
                        form.isSubmitting ||
                            form.isCancelling ||
                            controller.isDescriptionOverLimit
                        ? null
                        : () async {
                            if (!await ensureSubscriptionAllowsWrite(
                              context,
                              ref,
                            )) {
                              return;
                            }
                            final success = await controller.submit();
                            if (success && mounted) panelStack.pop();
                          },
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _CancelButton(
                      label: form.isCancelling
                          ? ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupSubmittingLabel,
                              ),
                            )
                          : ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.groupSessionsCancelButton,
                              ),
                            ),
                      onPressed: form.isSubmitting || form.isCancelling
                          ? null
                          : () async {
                              final success = await controller.cancel();
                              if (success && mounted) panelStack.pop();
                            },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _studioNameController.dispose();
    _descriptionController.dispose();
    _descriptionScrollController.dispose();
    super.dispose();
  }
}

/// Sadece düzenleme modunda görünür — dersi listeden kaldırmaz, `status:
/// cancelled` ile işaretler (bkz. `CreateGroupSessionController.cancel`).
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final disabled = onPressed == null;

    return Material(
      color: colors.errorContainer,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.primaryActionHeight,
          ),
          width: double.infinity,
          alignment: Alignment.center,
          child: Text(
            label,
            style: typography.headingSmall.copyWith(
              fontSize: 15,
              color: disabled ? colors.onSurfaceMuted : colors.error,
            ),
          ),
        ),
      ),
    );
  }
}

/// Antrenör atama — opsiyonel, çoklu seçim. `create_session_sheet.dart`'taki
/// düet üye seçim sheet'inin (`_pickMultipleFromList`) aynı deseni,
/// antrenörler için.
void _pickTrainers(
  BuildContext context,
  WidgetRef ref,
  CreateGroupSessionController controller,
  CreateGroupSessionForm form,
) {
  final colors = context.appColors;
  final typography = context.appTypography;
  final allTrainers = ref.read(adminTrainersControllerProvider);
  final selected = allTrainers
      .where((t) => form.trainerIds.contains(t.id))
      .toList();

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
                ref.read(
                  rcTextProvider(
                    RemoteConfigKeys.groupSessionsTrainerPickerTitle,
                  ),
                ),
                style: typography.headingMedium.copyWith(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final trainer in allTrainers)
                        InkWell(
                          onTap: () => setSheetState(() {
                            final index = selected.indexWhere(
                              (t) => t.id == trainer.id,
                            );
                            if (index >= 0) {
                              selected.removeAt(index);
                            } else {
                              selected.add(trainer);
                            }
                          }),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 52),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: selected.any(
                                    (t) => t.id == trainer.id,
                                  ),
                                  onChanged: (_) => setSheetState(() {
                                    final index = selected.indexWhere(
                                      (t) => t.id == trainer.id,
                                    );
                                    if (index >= 0) {
                                      selected.removeAt(index);
                                    } else {
                                      selected.add(trainer);
                                    }
                                  }),
                                ),
                                Expanded(
                                  child: Text(
                                    trainer.name,
                                    style: typography.bodyLarge.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 15,
                                    ),
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
                  controller.setTrainerIds(selected.map((t) => t.id).toList());
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

String _formatDate(WidgetRef ref, DateTime date) {
  final names = ref
      .read(rcTextProvider(RemoteConfigKeys.commonMonthNamesLong))
      .split(',');
  final month = date.month >= 1 && date.month <= names.length
      ? names[date.month - 1]
      : '';
  return '${date.day} $month ${date.year}';
}

Future<void> _pickStartTime(
  BuildContext context,
  CreateGroupSessionController controller,
  CreateGroupSessionForm form,
) async {
  final parts = form.startTime.split(':');
  final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: hour, minute: minute),
  );
  if (picked == null) return;
  final hh = picked.hour.toString().padLeft(2, '0');
  final mm = picked.minute.toString().padLeft(2, '0');
  controller.setStartTime('$hh:$mm');
}

const _durationOptions = [30, 45, 60, 75, 90, 120];

Future<void> _pickDuration(
  BuildContext context,
  CreateGroupSessionController controller,
  int current,
) {
  final colors = context.appColors;
  final typography = context.appTypography;
  final container = ProviderScope.containerOf(context);
  final durationSuffix = container.read(
    rcTextProvider(RemoteConfigKeys.groupSessionsDurationSuffix),
  );
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                container.read(
                  rcTextProvider(
                    RemoteConfigKeys.groupSessionsDurationPickerTitle,
                  ),
                ),
                style: typography.headingMedium.copyWith(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final minutes in _durationOptions)
                InkWell(
                  onTap: () {
                    controller.setDurationMinutes(minutes);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            durationSuffix.replaceAll('{minutes}', '$minutes'),
                            style: typography.bodyLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (minutes == current)
                          Icon(Icons.check, color: colors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Material(
      color: colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
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
                    Text(
                      value,
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceMuted,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: filled ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: filled ? colors.onPrimary : colors.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
