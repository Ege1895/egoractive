import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_currency_field.dart';
import '../../../../shared/widgets/app_phone_field.dart';
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
  late final PhoneController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _emailController;
  final _phoneFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Bu ekran her zaman sıfır bir salon kaydı temsil eder, bu yüzden alanlar
    // her açılışta boş başlar — sağdaki controller'lar `GymInfoPanel` (mevcut
    // salonu düzenleme) ile paylaşıldığı ve panel stack'te önceki panelleri
    // `maintainState` ile canlı tuttuğu için, `reset()` çağrısı olmadan eski
    // bir oturumdan kalan yazılmış değerler sızabilir. `reset()` bir provider
    // state ataması olduğu için build fazının bitmesini (post-frame) bekler.
    _nameController = TextEditingController();
    _cityController = TextEditingController();
    _phoneController = PhoneController(initialValue: PhoneNumber.parse('+90'));
    _addressController = TextEditingController();
    // Egoractive Authentication Sistemi §9 — "Login ve rapor e-postası",
    // GymProfile'a dahil değil (o model sadece zorunlu iletişim alanlarını
    // tutuyor); bu yüzden diğerlerinin aksine bir provider'a senkronize
    // edilmiyor, submit anında doğrudan okunuyor.
    _emailController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gymProfileControllerProvider.notifier).reset();
      ref.read(createGymControllerProvider.notifier).reset();
    });
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
    // "Bu numarayla kayıtlı bir hesap zaten var" gibi telefon hatası
    // ListView'de scroll'un altında kalabiliyordu — kullanıcı hatayı hiç
    // görmeden "Oluşturuluyor…" sonrası hiçbir şey olmamış gibi düşünüyordu.
    // Hata oluştuğunda alan otomatik olarak ekranın ortasına kaydırılır.
    ref.listen(createGymControllerProvider, (previous, next) {
      if (next.phoneError != null && previous?.phoneError != next.phoneError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = _phoneFieldKey.currentContext;
          if (context == null) return;
          Scrollable.ensureVisible(
            context,
            alignment: 0.5,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          );
        });
      }
    });

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                child: AppBackButton(
                  onTap: () =>
                      ref.read(panelStackControllerProvider.notifier).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.gymsGymSetupStepHeader),
                      ),
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.gymsGymSetupTitle),
                      ),
                      style: typography.headingLarge.copyWith(
                        color: colors.onSurface,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.gymsGymSetupHeadline),
                      ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
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
                                RemoteConfigKeys.gymsGymInfoNameFieldLabel,
                              ),
                            ),
                            controller: _nameController,
                            errorText: createGymState.nameError,
                            onChanged: profileController.updateName,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupCityFieldLabel,
                              ),
                            ),
                            controller: _cityController,
                            errorText: createGymState.cityError,
                            onChanged: profileController.updateCity,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppPhoneField(
                            key: _phoneFieldKey,
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupPhoneFieldLabel,
                              ),
                            ),
                            controller: _phoneController,
                            errorText: createGymState.phoneError,
                            onChanged: (e164, isValid) => profileController
                                .updatePhone(e164, isValid: isValid),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupPhoneHelperNote,
                              ),
                            ),
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .gymsGymInfoLoginReportEmailLabel,
                              ),
                            ),
                            hint: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymInfoGymReportEmailHint,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            errorText: createGymState.emailError,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .gymsGymSetupReportEmailDescription,
                              ),
                            ),
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymInfoAddressFieldLabel,
                              ),
                            ),
                            controller: _addressController,
                            errorText: createGymState.addressError,
                            onChanged: profileController.updateAddress,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppCurrencyField(
                            currencyCode: createGymState.currency,
                            locale: ref.watch(localeControllerProvider),
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupCurrencyFieldLabel,
                              ),
                            ),
                            onChanged: createGymController.selectCurrency,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupCurrencyHelperNote,
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
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupLogoOptionalLabel,
                              ),
                            ),
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupLogoDescription,
                              ),
                            ),
                            style: typography.bodyMedium.copyWith(
                              color: colors.onSurfaceMuted,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupLogoColorHintNote,
                              ),
                            ),
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (createGymState.logoFile != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInner,
                              ),
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
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            child: InkWell(
                              onTap: createGymController.pickLogo,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInner,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 44,
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  createGymState.logoFile == null
                                      ? ref.watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .gymsGymSetupChooseLogoButton,
                                          ),
                                        )
                                      : ref.watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .gymsGymInfoChangeLogoButton,
                                          ),
                                        ),
                                  style: typography.headingSmall.copyWith(
                                    fontSize: 14,
                                    color: colors.onSurfaceVariant,
                                  ),
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
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            createGymState.logoPalette.isNotEmpty
                                ? ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .gymsGymSetupSuggestedColorsLabel,
                                    ),
                                  )
                                : ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .gymsGymSetupThemeColorLabel,
                                    ),
                                  ),
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (createGymState.isExtractingPalette)
                            Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .gymsGymInfoPaletteExtractingLabel,
                                    ),
                                  ),
                                  style: typography.bodyMedium.copyWith(
                                    color: colors.onSurfaceMuted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          else if (createGymState.logoPalette.isNotEmpty)
                            Row(
                              children: [
                                for (final color in createGymState.logoPalette)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.md,
                                    ),
                                    child: _ColorSwatch(
                                      color: color,
                                      selected:
                                          color.toARGB32() ==
                                          createGymState.selectedPaletteColor
                                              ?.toARGB32(),
                                      onTap: () => createGymController
                                          .selectPaletteColor(color),
                                    ),
                                  ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                for (final swatch in themeState.themes)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.md,
                                    ),
                                    child: _ThemeSwatch(
                                      theme: swatch,
                                      selected:
                                          swatch.id == themeState.activeThemeId,
                                      onTap: () => themeController.selectTheme(
                                        swatch.id,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupChangeLaterNote,
                              ),
                            ),
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
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
                    if (createGymState.errorMessage != null) ...[
                      Text(
                        createGymState.errorMessage!,
                        style: typography.bodyMedium.copyWith(
                          color: colors.error,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    AppButton(
                      label: createGymState.isSubmitting
                          ? ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupSubmittingLabel,
                              ),
                            )
                          : ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.gymsGymSetupSubmitButton,
                              ),
                            ),
                      onPressed: createGymState.isSubmitting
                          ? null
                          : () async {
                              final gymId = await createGymController.submit(
                                email: _emailController.text,
                              );
                              if (gymId != null && mounted) {
                                ref
                                    .read(panelStackControllerProvider.notifier)
                                    .push(
                                      PhoneLoginPanel(
                                        // F8-4 — bu ekran artık AppPhoneField
                                        // kullanıyor, `phone` zaten tam E.164.
                                        prefillPhoneE164: ref
                                            .read(gymProfileControllerProvider)
                                            .phone,
                                        successBanner: ref.read(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .gymsGymSetupSuccessBanner,
                                          ),
                                        ),
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

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
          border: Border.all(
            color: selected ? theme.primary : colors.outlineStrong,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.primary,
          ),
        ),
      ),
    );
  }
}

/// [_ThemeSwatch] ile aynı görünüm, ama hazır bir [GymTheme] presetine değil
/// logodan çıkarılan ham bir [Color]'a bağlı (palette_generator önerisi).
class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final Color color;
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
          color: color.withValues(alpha: 0.16),
          border: Border.all(
            color: selected ? color : colors.outlineStrong,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      ),
    );
  }
}
