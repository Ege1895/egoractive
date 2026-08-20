import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/admin_trainers_controller.dart';
import '../../domain/admin_trainer_summary.dart';
import 'admin_trainer_detail_panel.dart';

/// Admin 3 · Antrenör Yönetimi — liste + antrenör ekle (alt sayfa formu).
class AdminTrainerManagementPanel extends BasePanel {
  const AdminTrainerManagementPanel({super.key});

  @override
  ConsumerState<AdminTrainerManagementPanel> createState() =>
      _AdminTrainerManagementPanelState();
}

class _AdminTrainerManagementPanelState
    extends BasePanelState<AdminTrainerManagementPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final trainers = ref.watch(adminTrainersControllerProvider);
    final trainerCountText = ref
        .watch(
          rcTextProvider(RemoteConfigKeys.trainersManagementTrainerCountSuffix),
        )
        .replaceAll('{count}', '${trainers.length}');
    final memberCountText = ref.watch(
      rcTextProvider(RemoteConfigKeys.trainersMemberCountSuffix),
    );

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
                  AppBackButton(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.trainersManagementTitle,
                        ),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Text(
                    trainerCountText,
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 15,
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
                  for (final trainer in trainers)
                    _TrainerRow(
                      trainer: trainer,
                      memberCountText: memberCountText,
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(AdminTrainerDetailPanel(trainer: trainer)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                0,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: ref.watch(
                  rcTextProvider(RemoteConfigKeys.trainersAddTrainerButton),
                ),
                variant: AppButtonVariant.secondary,
                onPressed: () => _showAddTrainerSheet(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTrainerSheet(BuildContext context, WidgetRef ref) {
    showTrainerFormSheet(context);
  }
}

/// Antrenör ekle (`admin_trainer_management_panel.dart`) ve düzenle
/// (`admin_trainer_detail_panel.dart`) aynı formu paylaşır — `existing`
/// verilirse alanlar önceki değerlerle dolu açılır ve kaydedince
/// `updateTrainer` çağrılır.
void showTrainerFormSheet(
  BuildContext context, {
  AdminTrainerSummary? existing,
}) {
  final colors = context.appColors;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _TrainerFormSheet(existing: existing),
  );
}

/// `trainerSpecialtyOptions`'daki her sabit uzmanlık için RC anahtarı —
/// depolanan/karşılaştırılan değer (Firestore'a yazılan, seçili durumun
/// kontrolünde kullanılan) hep Türkçe sabit string kalır, sadece gösterim
/// dile göre değişir.
String _specialtyKey(String specialty) => switch (specialty) {
  'Fonksiyonel' => RemoteConfigKeys.trainersSpecialtyFonksiyonelOption,
  'Pilates' => RemoteConfigKeys.trainersSpecialtyPilatesOption,
  'Yoga' => RemoteConfigKeys.trainersSpecialtyYogaOption,
  'Kickbox' => RemoteConfigKeys.trainersSpecialtyKickboxOption,
  _ => RemoteConfigKeys.trainersSpecialtyFonksiyonelOption,
};

class _TrainerRow extends StatelessWidget {
  const _TrainerRow({
    required this.trainer,
    required this.memberCountText,
    required this.onTap,
  });

  final AdminTrainerSummary trainer;
  final String memberCountText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(color: colors.outline),
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
                    trainer.initials,
                    style: typography.headingSmall.copyWith(
                      color: colors.onPrimaryContainer,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: typography.headingSmall.copyWith(
                          color: colors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${trainer.specialties.join(", ")} · '
                        '${memberCountText.replaceAll('{count}', '${trainer.memberCount}')}',
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrainerFormSheet extends ConsumerStatefulWidget {
  const _TrainerFormSheet({this.existing});

  final AdminTrainerSummary? existing;

  @override
  ConsumerState<_TrainerFormSheet> createState() => _TrainerFormSheetState();
}

class _TrainerFormSheetState extends ConsumerState<_TrainerFormSheet> {
  late final _nameController = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.existing == null
        ? ''
        : widget.existing!.phone
              .replaceAll(RegExp(r'[^0-9]'), '')
              .replaceFirst(RegExp(r'^90'), ''),
  );
  late final Set<String> _selectedSpecialties = {
    ...?widget.existing?.specialties,
  };
  bool _isSaving = false;
  String? _nameError;
  String? _errorMessage;

  bool get _isEditing => widget.existing != null;

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final nameRequiredError = ref.read(
      rcTextProvider(RemoteConfigKeys.trainersAddTrainerNameRequiredError),
    );
    setState(() => _nameError = name.isEmpty ? nameRequiredError : null);
    if (_nameError != null) return;
    if (!await ensureSubscriptionAllowsWrite(context, ref)) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final specialties = _selectedSpecialties.isEmpty
        ? ['Fonksiyonel']
        : _selectedSpecialties.toList();
    try {
      final notifier = ref.read(adminTrainersControllerProvider.notifier);
      if (_isEditing) {
        await notifier.updateTrainer(
          id: widget.existing!.id,
          name: name,
          phoneNumber: phoneDigits.isEmpty ? '' : '+90$phoneDigits',
          specialties: specialties,
        );
      } else {
        await notifier.addTrainer(
          name: name,
          phoneNumber: phoneDigits.isEmpty ? '' : '+90$phoneDigits',
          specialties: specialties,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = ref.read(
            rcTextProvider(
              _isEditing
                  ? RemoteConfigKeys.trainersEditTrainerError
                  : RemoteConfigKeys.trainersAddTrainerError,
            ),
          );
        });
      }
      return;
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.lg,
        AppSpacing.screenEdge,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.outlineStrong,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            ref.watch(
              rcTextProvider(
                _isEditing
                    ? RemoteConfigKeys.trainersEditTrainerFormTitle
                    : RemoteConfigKeys.trainersAddTrainerFormTitle,
              ),
            ),
            style: typography.headingLarge.copyWith(
              color: colors.onSurface,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.trainersFullNameFieldLabel),
            ),
            controller: _nameController,
            errorText: _nameError,
            hint: ref.watch(
              rcTextProvider(RemoteConfigKeys.trainersAddTrainerNameHint),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: ref.watch(
              rcTextProvider(RemoteConfigKeys.commonTelefonLabel),
            ),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [TrPhoneNumberInputFormatter()],
            hint: ref.watch(
              rcTextProvider(RemoteConfigKeys.membersInfoPhoneHint),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            ref.watch(
              rcTextProvider(RemoteConfigKeys.trainersSpecialtyFieldLabel),
            ),
            style: typography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            onTap: _showSpecialtyPicker,
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.watch(
                      rcTextProvider(
                        _specialtyKey(
                          _selectedSpecialties.isEmpty
                              ? 'Fonksiyonel'
                              : _selectedSpecialties.first,
                        ),
                      ),
                    ),
                    style: typography.bodyLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: 15,
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
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
            label: _isSaving
                ? ref.watch(
                    rcTextProvider(
                      _isEditing
                          ? RemoteConfigKeys.gymsGymInfoSavingLabel
                          : RemoteConfigKeys.trainersAddTrainerSavingLabel,
                    ),
                  )
                : ref.watch(
                    rcTextProvider(
                      _isEditing
                          ? RemoteConfigKeys.commonKaydet
                          : RemoteConfigKeys.trainersAddTrainerSubmitButton,
                    ),
                  ),
            onPressed: _isSaving ? null : _submit,
          ),
        ],
      ),
    );
  }

  void _showSpecialtyPicker() {
    final colors = context.appColors;
    final current = _selectedSpecialties.isEmpty
        ? 'Fonksiyonel'
        : _selectedSpecialties.first;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenEdge,
            AppSpacing.lg,
            AppSpacing.screenEdge,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colors.outlineStrong,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final specialty in trainerSpecialtyOptions)
                _SpecialtyPickerRow(
                  label: ref.watch(rcTextProvider(_specialtyKey(specialty))),
                  selected: specialty == current,
                  onTap: () {
                    setState(
                      () => _selectedSpecialties
                        ..clear()
                        ..add(specialty),
                    );
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class _SpecialtyPickerRow extends StatelessWidget {
  const _SpecialtyPickerRow({
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
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            if (selected) Icon(Icons.check, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
