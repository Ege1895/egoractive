import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../service/events_write_service.dart';

const _monthAbbrevToNumber = {
  'Oca': 1,
  'Şub': 2,
  'Mar': 3,
  'Nis': 4,
  'May': 5,
  'Haz': 6,
  'Tem': 7,
  'Ağu': 8,
  'Eyl': 9,
  'Eki': 10,
  'Kas': 11,
  'Ara': 12,
};

/// Admin 13 · Etkinlik Oluştur — lokasyon, tarih/saat, kontenjan.
class CreateEventPanel extends BasePanel {
  const CreateEventPanel({super.key});

  @override
  ConsumerState<CreateEventPanel> createState() => _CreateEventPanelState();
}

class _CreateEventPanelState extends BasePanelState<CreateEventPanel> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _capacity;
  bool _isSaving = false;
  String? _nameError;
  String? _dateError;
  String? _errorMessage;

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
                        rcTextProvider(RemoteConfigKeys.eventsCreateTitle),
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
                                onChanged: (_) {
                                  if (_dateError != null) {
                                    setState(() => _dateError = null);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppTextField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsTimeFieldLabel,
                                  ),
                                ),
                                controller: _timeController,
                                keyboardType: TextInputType.datetime,
                                hint: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.eventsTimeFieldHint,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.eventsDescriptionFieldLabel,
                            ),
                          ),
                          controller: _descriptionController,
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
                              RemoteConfigKeys.eventsCreateSubmitButton,
                            ),
                          ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final name = _nameController.text.trim();
                            final dateTime = _parseDateTime(
                              _dateController.text,
                              _timeController.text,
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
                              await ref
                                  .read(eventsWriteServiceProvider)
                                  .createEvent(
                                    gymId: gymId,
                                    name: name,
                                    location: _locationController.text.trim(),
                                    dateTime: dateTime!,
                                    description: _descriptionController.text
                                        .trim(),
                                    capacity: _capacity,
                                  );
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "16 Ağu 2026" + "08:00" formatlarını ayrıştırır — geçersizse null.
  DateTime? _parseDateTime(String dateText, String timeText) {
    final dateParts = dateText.trim().split(RegExp(r'\s+'));
    if (dateParts.length != 3) return null;
    final day = int.tryParse(dateParts[0]);
    final month = _monthAbbrevToNumber[dateParts[1]];
    final year = int.tryParse(dateParts[2]);
    if (day == null || month == null || year == null) return null;

    final timeParts = timeText.trim().split(':');
    final hour = timeParts.isNotEmpty ? int.tryParse(timeParts[0]) ?? 0 : 0;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

    return DateTime(year, month, day, hour, minute);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
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
