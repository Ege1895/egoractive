import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_phone_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../../trainers/controller/admin_trainers_controller.dart';
import '../../../trainers/domain/admin_trainer_summary.dart';
import '../../controller/member_registration_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../domain/admin_member_summary.dart';
import '../../domain/new_member_form.dart';
import 'new_membership_package_panel.dart';
import '../../../../shared/utils/date_labels.dart';

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
  late final PhoneController _phoneController;
  late final TextEditingController _noteController;
  final _noteScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final parts = widget.existing!.name.split(' ');
      _firstNameController = TextEditingController(text: parts.first);
      _lastNameController = TextEditingController(
        text: parts.skip(1).join(' '),
      );
      final existingPhone = widget.existing!.phone;
      _phoneController = PhoneController(
        initialValue: initialPhoneNumber(existingPhone),
      );
      _noteController = TextEditingController();
      // Kaydet, NewMemberController'ın form state'ini okuyor — telefon
      // alanına hiç dokunulmasa bile geçerli bir değer olsun diye mevcut
      // üyenin numarası buraya da yazılıyor (aksi halde phoneE164 boş
      // kalır ve validasyon "geçersiz numara" hatası verir).
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final notifier = ref.read(newMemberControllerProvider.notifier);
        notifier.reset();
        if (existingPhone.isNotEmpty) notifier.setInitialPhone(existingPhone);
        // `AdminMemberSummary` (widget.existing) bu alanı taşımıyor —
        // yazmadan önce gerçek değeri okumazsak her "Kaydet" yetkiyi
        // sessizce false'a resetlerdi.
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.existing!.id)
            .get();
        if (!mounted) return;
        notifier.setCanConfirmAttendance(
          doc.data()?['canConfirmAttendance'] as bool? ?? false,
        );
      });
    } else {
      // Yeni üye sihirbazı: bu provider panel stack'te önceki panelleri
      // canlı tuttuğu için önceki (iptal edilmiş) bir kayıttan kalan veri
      // sızmasın diye alanlar her zaman boş başlar (bkz. NewMemberController.reset).
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _phoneController = PhoneController(initialValue: initialPhoneNumber());
      _noteController = TextEditingController();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(newMemberControllerProvider.notifier).reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final controller = ref.read(newMemberControllerProvider.notifier);
    final form = ref.watch(newMemberControllerProvider);
    final registrationState = ref.watch(memberRegistrationControllerProvider);
    final registrationController = ref.read(
      memberRegistrationControllerProvider.notifier,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.isNew
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersInfoNewTitle,
                                ),
                              )
                            : ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersInfoEditTitle,
                                ),
                              ),
                        style: typography.headingSmall.copyWith(
                          color: colors.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => ref
                            .read(panelStackControllerProvider.notifier)
                            .pop(),
                        child: Text(
                          ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonVazgec),
                          ),
                          style: typography.bodyLarge.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.isNew) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Container(
                            height: 5,
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersInfoStepIndicator1,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            fontSize: 13,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
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
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersFirstNameFieldLabel,
                                  ),
                                ),
                                controller: _firstNameController,
                                errorText: registrationState.nameError,
                                onChanged: controller.updateFirstName,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppTextField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersLastNameFieldLabel,
                                  ),
                                ),
                                controller: _lastNameController,
                                onChanged: controller.updateLastName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppPhoneField(
                          label: ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonTelefonLabel),
                          ),
                          controller: _phoneController,
                          errorText: registrationState.phoneError,
                          onChanged: (e164, isValid) =>
                              controller.updatePhone(e164, isValid: isValid),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersInfoLoginHelper,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _StepperField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersBirthYearFieldLabel,
                                  ),
                                ),
                                value: '${form.birthYear}',
                                suffix: ref
                                    .watch(
                                      rcTextProvider(
                                        RemoteConfigKeys.membersInfoAgeSuffix,
                                      ),
                                    )
                                    .replaceAll('{age}', '${form.age}'),
                                onMinus: () => controller.updateBirthYear(
                                  form.birthYear - 1,
                                ),
                                onPlus: () => controller.updateBirthYear(
                                  form.birthYear + 1,
                                ),
                                onTapValue: () => _showNumberWheelPicker(
                                  context: context,
                                  title: ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .membersBirthYearFieldLabel,
                                    ),
                                  ),
                                  min: 1940,
                                  max: 2020,
                                  initial: form.birthYear,
                                  onSelected: controller.updateBirthYear,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _StepperField(
                                label: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersHeightFieldLabel,
                                  ),
                                ),
                                value: '${form.heightCm}',
                                suffix: ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.measurementsUnitCm,
                                  ),
                                ),
                                onMinus: () => controller.updateHeightCm(
                                  form.heightCm - 1,
                                ),
                                onPlus: () => controller.updateHeightCm(
                                  form.heightCm + 1,
                                ),
                                onTapValue: () => _showNumberWheelPicker(
                                  context: context,
                                  title: ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .membersInfoHeightPickerTitle,
                                    ),
                                  ),
                                  min: 130,
                                  max: 210,
                                  initial: form.heightCm,
                                  onSelected: controller.updateHeightCm,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersInfoGenderLabel,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final gender in MemberGender.values)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: gender == MemberGender.values.last
                                        ? 0
                                        : AppSpacing.sm,
                                  ),
                                  child: _GenderChip(
                                    label: ref.watch(
                                      rcTextProvider(
                                        gender == MemberGender.erkek
                                            ? RemoteConfigKeys
                                                  .membersInfoGenderErkekOption
                                            : RemoteConfigKeys
                                                  .membersInfoGenderKadinOption,
                                      ),
                                    ),
                                    selected: form.gender == gender,
                                    onTap: () =>
                                        controller.toggleGender(gender),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersInfoGenderHelper,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      ],
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
                        InkWell(
                          onTap: () => _showTrainerPicker(context, controller),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color:
                                      widget.isNew &&
                                          registrationState.trainerError != null
                                      ? colors.error
                                      : colors.outline,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .membersTrainerFieldLabel,
                                      ),
                                    ),
                                    style: typography.bodyLarge.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            form.trainerName ??
                                                ref.watch(
                                                  rcTextProvider(
                                                    RemoteConfigKeys
                                                        .membersSelectTrainerButton,
                                                  ),
                                                ),
                                            style: typography.headingSmall
                                                .copyWith(
                                                  color:
                                                      form.trainerName == null
                                                      ? colors.onSurfaceMuted
                                                      : colors.onSurface,
                                                  fontSize: 15,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Icon(
                                          Icons.chevron_right,
                                          color: colors.onSurfaceMuted,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.isNew &&
                            registrationState.trainerError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              registrationState.trainerError!,
                              style: typography.bodyMedium.copyWith(
                                color: colors.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        InkWell(
                          onTap: widget.isNew
                              ? () => showNativeDatePicker(
                                  context: context,
                                  initial: form.registeredAt,
                                  firstDate: DateTime(DateTime.now().year - 50),
                                  lastDate: DateTime.now(),
                                  onSelected: controller.updateRegisteredAt,
                                )
                              : null,
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 60),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    ref.watch(
                                      rcTextProvider(
                                        RemoteConfigKeys
                                            .membersRegistrationDateFieldLabel,
                                      ),
                                    ),
                                    style: typography.bodyLarge.copyWith(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  // Mevcut üye düzenlenirken gerçek kayıt tarihi
                                  // henüz Firestore'dan okunmuyor (ayrı kapsam).
                                  widget.isNew
                                      ? ref
                                            .watch(dateLabelsProvider)
                                            .dayMonthYear(form.registeredAt)
                                      : '—',
                                  style: typography.headingSmall.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                if (widget.isNew) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    Icons.chevron_right,
                                    color: colors.onSurfaceMuted,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Scrollbar(
                    controller: _noteScrollController,
                    thumbVisibility: true,
                    interactive: true,
                    thickness: 4,
                    radius: const Radius.circular(4),
                    child: AppTextField(
                      label: ref.watch(
                        rcTextProvider(RemoteConfigKeys.membersNoteFieldLabel),
                      ),
                      controller: _noteController,
                      scrollController: _noteScrollController,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: controller.updateNote,
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
                                    RemoteConfigKeys
                                        .membersInfoConfirmAttendanceLabel,
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
                                        .membersInfoConfirmAttendanceHelper,
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
                          onTap: controller.toggleCanConfirmAttendance,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 52,
                            height: 32,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: form.canConfirmAttendance
                                  ? colors.primary
                                  : colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusPill,
                              ),
                            ),
                            alignment: form.canConfirmAttendance
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
                  if (registrationState.errorMessage != null) ...[
                    Text(
                      registrationState.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: widget.isNew
                        ? (registrationState.isSubmitting
                              ? ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersSavingLabel,
                                  ),
                                )
                              : ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .membersInfoGoToPackageButton,
                                  ),
                                ))
                        : (registrationState.isSubmitting
                              ? ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.membersSavingLabel,
                                  ),
                                )
                              : ref.watch(
                                  rcTextProvider(RemoteConfigKeys.commonKaydet),
                                )),
                    onPressed: registrationState.isSubmitting
                        ? null
                        : () async {
                            if (!await ensureSubscriptionAllowsWrite(
                              context,
                              ref,
                            )) {
                              return;
                            }
                            if (!widget.isNew) {
                              final success = await registrationController
                                  .submitEdit(memberId: widget.existing!.id);
                              if (success && mounted) {
                                ref
                                    .read(panelStackControllerProvider.notifier)
                                    .pop();
                              }
                              return;
                            }
                            final success = await registrationController
                                .submit();
                            if (success && mounted) {
                              ref
                                  .read(panelStackControllerProvider.notifier)
                                  .push(const NewMembershipPackagePanel());
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

  void _showTrainerPicker(
    BuildContext context,
    NewMemberController controller,
  ) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
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
                  ref.read(
                    rcTextProvider(RemoteConfigKeys.membersSelectTrainerButton),
                  ),
                  style: context.appTypography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // `ref.read` ile tek seferlik alınan liste, sheet açıldığı
                // anda antrenörler Firestore'dan henüz gelmemişse (ilk
                // dinlemede stream henüz ilk snapshot'ını vermemişse) hep
                // boş kalıyordu — sheet kendi build'i yenilenmediği için
                // veri gelse bile ekrana yansımıyordu. Consumer ile
                // reaktif izleniyor.
                Consumer(
                  builder: (context, ref, _) {
                    final trainers = ref.watch(adminTrainersControllerProvider);
                    if (trainers.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.lg,
                        ),
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersInfoNoTrainersMessage,
                            ),
                          ),
                          style: context.appTypography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final trainer in trainers)
                          _TrainerOption(
                            trainer: trainer,
                            onTap: () {
                              controller.selectTrainer(
                                trainer.id,
                                trainer.name,
                              );
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Boy/doğum yılı için +/- tek tek artırmanın yerine tam bir aralığı
  /// hızlıca taramak üzere iOS'un native scroll wheel'iyle aynı bileşen
  /// (CupertinoPicker) kullanılıyor — Flutter SDK'da Android'e özgü ayrı
  /// bir "native" tekerlek bileşeni yok, bu yüzden iki platformda da aynı
  /// alt sayfa gösteriliyor.
  Future<void> _showNumberWheelPicker({
    required BuildContext context,
    required String title,
    required int min,
    required int max,
    required int initial,
    required ValueChanged<int> onSelected,
  }) async {
    final colors = context.appColors;
    final values = [for (var v = min; v <= max; v++) v];
    var selected = initial.clamp(min, max);
    final initialIndex = values.indexOf(selected);

    await showModalBottomSheet<void>(
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
              children: [
                Text(
                  title,
                  style: context.appTypography.headingSmall.copyWith(
                    color: colors.onSurface,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 216,
                  child: CupertinoPicker(
                    scrollController: FixedExtentScrollController(
                      initialItem: initialIndex < 0 ? 0 : initialIndex,
                    ),
                    itemExtent: 40,
                    onSelectedItemChanged: (index) => selected = values[index],
                    children: [
                      for (final v in values)
                        Center(
                          child: Text(
                            '$v',
                            style: context.appTypography.dataMedium.copyWith(
                              color: colors.onSurface,
                              fontSize: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: ref.read(
                    rcTextProvider(
                      RemoteConfigKeys.membersInfoPickerConfirmButton,
                    ),
                  ),
                  onPressed: () {
                    onSelected(selected);
                    Navigator.of(sheetContext).pop();
                  },
                ),
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
    _noteScrollController.dispose();
    super.dispose();
  }
}

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.suffix,
    required this.onMinus,
    required this.onPlus,
    required this.onTapValue,
  });

  final String label;
  final String value;
  final String suffix;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onTapValue;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.bodyMedium.copyWith(
            color: colors.onSurfaceMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onMinus,
                child: Icon(
                  Icons.remove_circle_outline,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onTapValue,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: typography.dataMedium.copyWith(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onPlus,
                child: Icon(
                  Icons.add_circle_outline,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          suffix,
          style: typography.caption.copyWith(color: colors.onPrimaryContainer),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  const _GenderChip({
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? colors.primary : colors.outlineStrong,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: typography.headingSmall.copyWith(
                  fontSize: 15,
                  color: selected
                      ? colors.onPrimaryContainer
                      : colors.onSurface,
                ),
              ),
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
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                trainer.initials,
                style: typography.headingSmall.copyWith(
                  color: colors.onPrimaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              trainer.name,
              style: typography.bodyLarge.copyWith(
                color: colors.onSurface,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
