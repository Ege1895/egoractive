import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/controller/member_profile_controller.dart';
import '../../service/member_registration_service.dart';

/// Üye · Bilgilerim — üyenin kendi ad/soyad/telefon bilgisini görüntüleyip
/// düzenleyebildiği panel. Profil ve Ana Sayfa'daki isim kartlarından açılır.
class MemberSelfInfoPanel extends BasePanel {
  const MemberSelfInfoPanel({super.key});

  @override
  ConsumerState<MemberSelfInfoPanel> createState() =>
      _MemberSelfInfoPanelState();
}

class _MemberSelfInfoPanelState extends BasePanelState<MemberSelfInfoPanel> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;

  bool _isSaving = false;
  String? _nameError;
  String? _phoneError;
  String? _saveErrorMessage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(memberProfileControllerProvider);
    final parts = profile.name.trim().split(RegExp(r'\s+'));
    _firstNameController = TextEditingController(
      text: parts.isEmpty ? '' : parts.first,
    );
    _lastNameController = TextEditingController(
      text: parts.length > 1 ? parts.skip(1).join(' ') : '',
    );
    _phoneController = TextEditingController(
      text: formatTrPhoneDigits(profile.phoneDigits),
    );
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
                  AppBackButton(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.membersSelfInfoTitle),
                    ),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
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
                                errorText: _nameError,
                                onChanged: (_) {
                                  if (_nameError != null) {
                                    setState(() => _nameError = null);
                                  }
                                },
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
                                onChanged: (_) {
                                  if (_nameError != null) {
                                    setState(() => _nameError = null);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonTelefonLabel),
                          ),
                          prefixText: '+90 ',
                          keyboardType: TextInputType.number,
                          controller: _phoneController,
                          inputFormatters: [TrPhoneNumberInputFormatter()],
                          errorText: _phoneError,
                          onChanged: (_) {
                            if (_phoneError != null) {
                              setState(() => _phoneError = null);
                            }
                          },
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_saveErrorMessage != null) ...[
                    Text(
                      _saveErrorMessage!,
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
                            rcTextProvider(RemoteConfigKeys.membersSavingLabel),
                          )
                        : ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonKaydet),
                          ),
                    onPressed: _isSaving ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final name = [firstName, lastName].where((p) => p.isNotEmpty).join(' ');
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    setState(() {
      _nameError = name.isEmpty
          ? ref.read(
              rcTextProvider(RemoteConfigKeys.membersSelfInfoNameRequiredError),
            )
          : null;
      _phoneError = phoneDigits.length != 10
          ? ref.read(
              rcTextProvider(RemoteConfigKeys.membersSelfInfoPhoneInvalidError),
            )
          : null;
      _saveErrorMessage = null;
    });
    if (_nameError != null || _phoneError != null) return;

    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final phoneNumber = '+90$phoneDigits';
    final service = ref.read(memberRegistrationServiceProvider);

    setState(() => _isSaving = true);
    try {
      final currentDigits = ref
          .read(memberProfileControllerProvider)
          .phoneDigits;
      if (phoneDigits != currentDigits &&
          await service.phoneNumberIsTaken(phoneNumber)) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
          _phoneError = ref.read(
            rcTextProvider(RemoteConfigKeys.membersSelfInfoPhoneTakenError),
          );
        });
        return;
      }
      await service.updateOwnInfo(
        memberId: uid,
        name: name,
        phoneNumber: phoneNumber,
      );
      if (!mounted) return;
      ref.read(panelStackControllerProvider.notifier).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveErrorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.membersSelfInfoSaveError),
        );
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
