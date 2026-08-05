import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../trainers/controller/admin_trainers_controller.dart';
import '../../../trainers/domain/admin_trainer_summary.dart';
import '../../controller/member_registration_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../domain/admin_member_summary.dart';
import '../../domain/new_member_form.dart';
import 'new_membership_package_panel.dart';

/// Admin 5 · Üye bilgileri — [existing] verilirse mevcut üyeyi görüntüle/
/// düzenle, verilmezse Yeni Üye kayıt sihirbazının 1. adımı (1/3).
class MemberInfoPanel extends BasePanel {
  const MemberInfoPanel({this.existing, super.key});

  final AdminMemberSummary? existing;

  bool get isNew => existing == null;

  @override
  ConsumerState<MemberInfoPanel> createState() => _MemberInfoPanelState();
}

class _MemberInfoPanelState extends BasePanelState<MemberInfoPanel> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final form = ref.read(newMemberControllerProvider);
    if (widget.existing != null) {
      final parts = widget.existing!.name.split(' ');
      _firstNameController = TextEditingController(text: parts.first);
      _lastNameController = TextEditingController(text: parts.skip(1).join(' '));
      _phoneController = TextEditingController(text: widget.existing!.phone);
      _noteController = TextEditingController();
    } else {
      _firstNameController = TextEditingController(text: form.firstName);
      _lastNameController = TextEditingController(text: form.lastName);
      _phoneController = TextEditingController(text: formatTrPhoneDigits(form.phoneDigits));
      _noteController = TextEditingController(text: form.note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final controller = ref.read(newMemberControllerProvider.notifier);
    final form = ref.watch(newMemberControllerProvider);
    final registrationState = ref.watch(memberRegistrationControllerProvider);
    final registrationController = ref.read(memberRegistrationControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.isNew ? 'Yeni üye' : 'Üye bilgileri', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                      GestureDetector(
                        onTap: () => ref.read(panelStackControllerProvider.notifier).pop(),
                        child: Text('Vazgeç', style: typography.bodyLarge.copyWith(color: colors.onSurfaceMuted, fontSize: 15)),
                      ),
                    ],
                  ),
                  if (widget.isNew) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: Container(height: 5, decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)))),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Container(height: 5, decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)))),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Container(height: 5, decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)))),
                        const SizedBox(width: AppSpacing.sm),
                        Text('1 / 3', style: typography.headingSmall.copyWith(fontSize: 13, color: colors.onPrimaryContainer)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  Container(
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
                          children: [
                            Expanded(child: AppTextField(label: 'Ad', controller: _firstNameController, onChanged: controller.updateFirstName)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: AppTextField(label: 'Soyad', controller: _lastNameController, onChanged: controller.updateLastName)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Telefon',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          onChanged: (value) => controller.updatePhoneDigits(value.replaceAll(RegExp(r'[^0-9]'), '')),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Üye bu numarayla giriş yapar, şifre yok.', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _StepperField(
                                label: 'Doğum yılı',
                                value: '${form.birthYear}',
                                suffix: '${form.age} yaş',
                                onMinus: () => controller.updateBirthYear(form.birthYear - 1),
                                onPlus: () => controller.updateBirthYear(form.birthYear + 1),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StepperField(
                                label: 'Boy',
                                value: '${form.heightCm}',
                                suffix: 'cm',
                                onMinus: () => controller.updateHeightCm(form.heightCm - 1),
                                onPlus: () => controller.updateHeightCm(form.heightCm + 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('Cinsiyet', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final gender in MemberGender.values)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: gender == MemberGender.values.last ? 0 : AppSpacing.sm),
                                  child: _GenderChip(
                                    label: gender.label,
                                    selected: form.gender == gender,
                                    onTap: () => controller.updateGender(gender),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Ölçüm avatarı bu bilgiye göre gösterilir; üye ekranında ayrıca seçim yapılmaz.',
                          style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => _showTrainerPicker(context, controller),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.outline))),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('Antrenör', style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          form.trainerName,
                                          style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text('Kayıt tarihi', style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
                              ),
                              Text('3 Ağu 2026', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: 'Not (isteğe bağlı)',
                    controller: _noteController,
                    onChanged: controller.updateNote,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isNew && registrationState.errorMessage != null) ...[
                    Text(
                      registrationState.errorMessage!,
                      style: typography.bodyMedium.copyWith(color: colors.error, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: widget.isNew
                        ? (registrationState.isSubmitting ? 'Kaydediliyor…' : 'Paket seçimine geç')
                        : 'Kaydet',
                    onPressed: widget.isNew && registrationState.isSubmitting
                        ? null
                        : () async {
                            if (!widget.isNew) {
                              ref.read(panelStackControllerProvider.notifier).pop();
                              return;
                            }
                            final success = await registrationController.submit();
                            if (success && mounted) {
                              ref.read(panelStackControllerProvider.notifier).push(const NewMembershipPackagePanel());
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

  void _showTrainerPicker(BuildContext context, NewMemberController controller) {
    final colors = context.appColors;
    final trainers = ref.read(adminTrainersControllerProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Antrenör seç', style: context.appTypography.headingMedium.copyWith(color: colors.onSurface, fontSize: 20)),
                const SizedBox(height: AppSpacing.md),
                for (final trainer in trainers) _TrainerOption(trainer: trainer, onTap: () {
                  controller.selectTrainer(trainer.id, trainer.name);
                  Navigator.of(sheetContext).pop();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({required this.label, required this.value, required this.suffix, required this.onMinus, required this.onPlus});

  final String label;
  final String value;
  final String suffix;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
          child: Row(
            children: [
              GestureDetector(onTap: onMinus, child: Icon(Icons.remove_circle_outline, color: colors.onSurfaceVariant, size: 20)),
              Expanded(
                child: Text(value, textAlign: TextAlign.center, style: typography.dataMedium.copyWith(color: colors.onSurface, fontSize: 16)),
              ),
              GestureDetector(onTap: onPlus, child: Icon(Icons.add_circle_outline, color: colors.onSurfaceVariant, size: 20)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(suffix, style: typography.caption.copyWith(color: colors.onPrimaryContainer)),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Material(
      color: selected ? colors.primaryContainer : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: 46),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: selected ? colors.primary : colors.outlineStrong, width: 2)),
                alignment: Alignment.center,
                child: selected ? Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary)) : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: typography.headingSmall.copyWith(fontSize: 15, color: selected ? colors.onPrimaryContainer : colors.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainerOption extends StatelessWidget {
  const _TrainerOption({required this.trainer, required this.onTap});

  final AdminTrainerSummary trainer;
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
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(trainer.initials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 13)),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(trainer.name, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
