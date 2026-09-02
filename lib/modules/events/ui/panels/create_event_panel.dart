import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/past_datetime_gate.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../service/events_write_service.dart';

/// Admin 13 · Etkinlik Oluştur — lokasyon, tarih/saat, kontenjan. [eventId]
/// verilirse düzenleme moduna geçer: mevcut etkinlik yüklenir, en altta
/// "İptal Et" görünür.
class CreateEventPanel extends BasePanel {
  const CreateEventPanel({super.key, this.eventId});

  final String? eventId;

  @override
  ConsumerState<CreateEventPanel> createState() => _CreateEventPanelState();
}

class _CreateEventPanelState extends BasePanelState<CreateEventPanel> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionScrollController = ScrollController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int? _capacity;
  bool _isSaving = false;
  bool _isLoadingForEdit = false;
  String? _nameError;
  String? _dateError;
  String? _errorMessage;

  bool get _isEditing => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    final id = widget.eventId;
    if (id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadForEdit(id));
    }
  }

  Future<void> _loadForEdit(String eventId) async {
    setState(() => _isLoadingForEdit = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();
      final data = doc.data();
      if (!mounted) return;
      if (data == null) {
        setState(() {
          _isLoadingForEdit = false;
          _errorMessage = ref.read(
            rcTextProvider(RemoteConfigKeys.eventsNotFoundError),
          );
        });
        return;
      }
      final dateTime = (data['dateTime'] as Timestamp).toDate();
      _nameController.text = (data['name'] as String?) ?? '';
      _locationController.text = (data['location'] as String?) ?? '';
      _descriptionController.text = (data['description'] as String?) ?? '';
      _selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
      _selectedTime = TimeOfDay.fromDateTime(dateTime);
      _dateController.text = _formatDate(_selectedDate!);
      _timeController.text = _formatTime(_selectedTime!);
      setState(() {
        _capacity = (data['capacity'] as num?)?.toInt();
        _isLoadingForEdit = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingForEdit = false;
        _errorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.eventsLoadError),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

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
                              ? RemoteConfigKeys.eventsEditTitle
                              : RemoteConfigKeys.eventsCreateTitle,
                        ),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
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
                              RemoteConfigKeys.eventsNameFieldLabel,
                            ),
                          ),
                          controller: _nameController,
                          errorText: _nameError,
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.eventsLocationFieldLabel,
                            ),
                          ),
                          controller: _locationController,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showNativeDatePicker(
                                  context: context,
                                  initial: _selectedDate ?? DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 1),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365 * 2),
                                  ),
                                  onSelected: (date) => setState(() {
                                    _selectedDate = date;
                                    _dateController.text = _formatDate(date);
                                    _dateError = null;
                                  }),
                                ),
                                child: AbsorbPointer(
                                  child: AppTextField(
                                    label: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys.eventsDateFieldLabel,
                                      ),
                                    ),
                                    controller: _dateController,
                                    hint: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys.eventsDateFieldHint,
                                      ),
                                    ),
                                    errorText: _dateError,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => showNativeTimePicker(
                                  context: context,
                                  initial: _selectedTime ?? TimeOfDay.now(),
                                  onSelected: (time) => setState(() {
                                    _selectedTime = time;
                                    _timeController.text = _formatTime(time);
                                  }),
                                ),
                                child: AbsorbPointer(
                                  child: AppTextField(
                                    label: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys.eventsTimeFieldLabel,
                                      ),
                                    ),
                                    controller: _timeController,
                                    hint: ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys.eventsTimeFieldHint,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                RemoteConfigKeys.eventsDescriptionFieldLabel,
                              ),
                            ),
                            controller: _descriptionController,
                            scrollController: _descriptionScrollController,
                            minLines: 1,
                            maxLines: 5,
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCapacityLabel,
                                  ),
                                ),
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .eventsCapacityEmptyMeansUnlimitedHelper,
                                  ),
                                ),
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StepButton(
                          icon: Icons.remove,
                          onTap: () => setState(
                            () => _capacity = _capacity == null
                                ? null
                                : (_capacity! > 1 ? _capacity! - 1 : null),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            _capacity?.toString() ?? '∞',
                            textAlign: TextAlign.center,
                            style: typography.dataMedium.copyWith(
                              color: colors.onSurface,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        _StepButton(
                          icon: Icons.add,
                          filled: true,
                          onTap: () =>
                              setState(() => _capacity = (_capacity ?? 0) + 1),
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
                    label: _isSaving
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymSetupSubmittingLabel,
                            ),
                          )
                        : ref.watch(
                            rcTextProvider(
                              _isEditing
                                  ? RemoteConfigKeys.eventsEditSubmitButton
                                  : RemoteConfigKeys.eventsCreateSubmitButton,
                            ),
                          ),
                    onPressed: _isSaving || _isLoadingForEdit
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            final selectedDate = _selectedDate;
                            final selectedTime = _selectedTime;
                            final dateTime = selectedDate == null
                                ? null
                                : DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime?.hour ?? 0,
                                    selectedTime?.minute ?? 0,
                                  );
                            var hasError = false;
                            if (name.isEmpty) {
                              setState(
                                () => _nameError = ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsNameRequiredError,
                                  ),
                                ),
                              );
                              hasError = true;
                            }
                            if (dateTime == null) {
                              setState(
                                () => _dateError = ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsDateFormatError,
                                  ),
                                ),
                              );
                              hasError = true;
                            } else if (isPastDatetimeCreationBlocked(
                              ref,
                              dateTime,
                            )) {
                              setState(
                                () => _dateError = ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.commonPastDatetimeError,
                                  ),
                                ),
                              );
                              hasError = true;
                            }
                            if (hasError) return;
                            if (!await ensureSubscriptionAllowsWrite(
                              context,
                              ref,
                            )) {
                              return;
                            }

                            setState(() {
                              _isSaving = true;
                              _errorMessage = null;
                            });
                            try {
                              final gymId = await ref.read(
                                activeGymIdProvider.future,
                              );
                              if (gymId == null) {
                                setState(() {
                                  _isSaving = false;
                                  _errorMessage = ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .sessionsCreateNoActiveGymError,
                                    ),
                                  );
                                });
                                return;
                              }
                              final service = ref.read(
                                eventsWriteServiceProvider,
                              );
                              final editingId = widget.eventId;
                              if (editingId != null) {
                                await service.updateEvent(
                                  eventId: editingId,
                                  name: name,
                                  location: _locationController.text.trim(),
                                  dateTime: dateTime!,
                                  description: _descriptionController.text
                                      .trim(),
                                  capacity: _capacity,
                                );
                              } else {
                                await service.createEvent(
                                  gymId: gymId,
                                  name: name,
                                  location: _locationController.text.trim(),
                                  dateTime: dateTime!,
                                  description: _descriptionController.text
                                      .trim(),
                                  capacity: _capacity,
                                );
                              }
                              if (mounted) {
                                ref
                                    .read(panelStackControllerProvider.notifier)
                                    .pop();
                              }
                            } catch (_) {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                  _errorMessage = ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys.eventsCreateFailedError,
                                    ),
                                  );
                                });
                              }
                            }
                          },
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _CancelButton(
                      label: ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.groupSessionsCancelButton,
                        ),
                      ),
                      onPressed: _isSaving || _isLoadingForEdit
                          ? null
                          : () async {
                              // Geri alınamaz aksiyon — önce onay. İşlem
                              // durumu ve hata gösterimi artık diyaloğun
                              // kendisinde.
                              final confirmed = await showAppConfirmDialog(
                                context: context,
                                title: ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCancelConfirmTitle,
                                  ),
                                ),
                                message: ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCancelConfirmBody,
                                  ),
                                ),
                                confirmLabel: ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCancelConfirmCta,
                                  ),
                                ),
                                cancelLabel: ref.read(
                                  rcTextProvider(RemoteConfigKeys.commonVazgec),
                                ),
                                busyLabel: ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .gymsGymSetupSubmittingLabel,
                                  ),
                                ),
                                errorMessage: ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsCancelError,
                                  ),
                                ),
                                onConfirm: () => ref
                                    .read(eventsWriteServiceProvider)
                                    .cancelEvent(widget.eventId!),
                              );
                              if (confirmed && mounted) {
                                ref
                                    .read(panelStackControllerProvider.notifier)
                                    .pop();
                              }
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

  String _formatDate(DateTime date) {
    final names = ref
        .read(rcTextProvider(RemoteConfigKeys.commonMonthNamesLong))
        .split(',');
    final month = date.month >= 1 && date.month <= names.length
        ? names[date.month - 1]
        : '';
    return '${date.day} $month ${date.year}';
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _descriptionScrollController.dispose();
    super.dispose();
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
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
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: filled ? colors.onPrimary : colors.onSurfaceVariant,
            size: 18,
          ),
        ),
      ),
    );
  }
}

/// Sadece düzenleme modunda görünür — etkinliği listeden kaldırmaz, `status:
/// cancelled` ile işaretler (bkz. `EventsWriteService.cancelEvent`).
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
