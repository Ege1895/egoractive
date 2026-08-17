import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/ui/panels/phone_login_panel.dart';
import '../../controller/create_gym_controller.dart';
import '../../controller/gym_profile_controller.dart';
import '../../controller/gym_theme_controller.dart';
import '../../domain/gym_theme.dart';

/// Admin · Salon Oluştur (ilk kurulum) — logo + tema, hesabı aktifleştirir.
class GymSetupPanel extends BasePanel {
  const GymSetupPanel({super.key});

  @override
  ConsumerState<GymSetupPanel> createState() => _GymSetupPanelState();
}

class _GymSetupPanelState extends BasePanelState<GymSetupPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(gymProfileControllerProvider);
    _nameController = TextEditingController(text: profile.name);
    _cityController = TextEditingController(text: profile.city);
    _phoneController = TextEditingController(text: profile.phone);
    _addressController = TextEditingController(text: profile.address);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final profileController = ref.read(gymProfileControllerProvider.notifier);
    final themeState = ref.watch(gymThemeControllerProvider);
    final themeController = ref.read(gymThemeControllerProvider.notifier);
    final createGymState = ref.watch(createGymControllerProvider);
    final createGymController = ref.read(createGymControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KURULUM 1 / 1', style: typography.caption.copyWith(color: colors.onSurfaceMuted, letterSpacing: 1.2)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Salonunu tanımla', style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 28)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bu adımı tamamlayınca yönetici hesabınız aktifleşir ve uygulamaya girersiniz.',
                    style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                  ),
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
                        AppTextField(
                          label: 'Salon adı',
                          controller: _nameController,
                          onChanged: profileController.updateName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Şehir',
                                controller: _cityController,
                                onChanged: profileController.updateCity,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppTextField(
                                label: 'Telefon',
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                onChanged: profileController.updatePhone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Adres',
                          controller: _addressController,
                          onChanged: profileController.updateAddress,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                        Text('Salon logosu (opsiyonel)', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Kare PNG, en az 512×512. Eklersen üyelerin ve antrenörlerin her ekranında arka planda %25 opaklıkla silüet olarak görünür — sonradan Salon Bilgileri panelinden de ekleyebilirsin.',
                          style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (createGymState.logoFile != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            child: Image.file(
                              File(createGymState.logoFile!.path),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        Material(
                          color: colors.surfaceRaised,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                          child: InkWell(
                            onTap: createGymController.pickLogo,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                              constraints: const BoxConstraints(minHeight: 44),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                createGymState.logoFile == null ? 'Logo seç' : 'Logoyu değiştir',
                                style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onSurfaceVariant),
                              ),
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
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tema rengi', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            for (final swatch in themeState.themes)
                              Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.md),
                                child: _ThemeSwatch(
                                  theme: swatch,
                                  selected: swatch.id == themeState.activeThemeId,
                                  onTap: () => themeController.selectTheme(swatch.id),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Sonradan Temalar panelinden değiştirebilirsiniz.',
                          style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (createGymState.errorMessage != null) ...[
                    Text(
                      createGymState.errorMessage!,
                      style: typography.bodyMedium.copyWith(color: colors.error, fontSize: 13),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: createGymState.isSubmitting ? 'Oluşturuluyor…' : 'Salonu oluştur ve girişi tamamla',
                    onPressed: createGymState.isSubmitting
                        ? null
                        : () async {
                            final gymId = await createGymController.submit();
                            if (gymId != null && mounted) {
                              final phoneDigits =
                                  ref.read(gymProfileControllerProvider).phone.replaceAll(RegExp(r'[^0-9]'), '');
                              ref.read(panelStackControllerProvider.notifier).replaceRoot(
                                    PhoneLoginPanel(
                                      prefillPhoneDigits: phoneDigits,
                                      successBanner:
                                          'Salonun oluşturuldu! Şimdi az önce girdiğin numarayla giriş yap.',
                                    ),
                                  );
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

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.theme, required this.selected, required this.onTap});

  final GymTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.primary.withValues(alpha: 0.16),
          border: Border.all(color: selected ? theme.primary : colors.outlineStrong, width: 2),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: theme.primary),
        ),
      ),
    );
  }
}
