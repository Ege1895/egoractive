import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/utils/gym_logo_image.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_currency_field.dart';
import '../../../../shared/widgets/app_phone_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/domain/otp_purpose.dart';
import '../../../auth/repository/auth_repository.dart';
import '../../../auth/ui/panels/otp_verification_panel.dart';
import '../../../reports/controller/report_recipients_controller.dart';
import '../../../reports/domain/report_recipients.dart';
import '../../controller/gym_profile_controller.dart';
import '../../controller/gym_theme_controller.dart';
import '../../domain/gym_theme.dart';
import '../../service/gym_logo_service.dart';
import 'gym_themes_panel.dart';

/// Admin 2 · Salon Bilgileri — düzenleme + Temalar'a giriş.
class GymInfoPanel extends BasePanel {
  const GymInfoPanel({super.key});

  @override
  ConsumerState<GymInfoPanel> createState() => _GymInfoPanelState();
}

class _GymInfoPanelState extends BasePanelState<GymInfoPanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final PhoneController _phoneController;
  late final TextEditingController _emailController;

  bool _isSaving = false;
  bool _hydratedFromProfile = false;
  bool _hydratedFromRecipients = false;
  String _originalEmail = '';
  String? _nameError;
  String? _addressError;
  String? _phoneError;
  String? _emailError;
  String? _saveErrorMessage;

  XFile? _pickedLogoFile;
  bool _isUploadingLogo = false;
  String? _logoError;

  List<Color> _logoPalette = const [];
  bool _isExtractingPalette = false;
  String? _paletteSourceKey;

  Color? _previewColor;
  late final Color _originalThemeColor;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(gymProfileControllerProvider);
    _nameController = TextEditingController(text: profile.name);
    _addressController = TextEditingController(
      text: '${profile.address}, ${profile.city}',
    );
    _phoneController = PhoneController(
      initialValue: initialPhoneNumber(profile.phone),
    );

    final recipients = ref.read(reportRecipientsControllerProvider);
    _emailController = TextEditingController(text: recipients.gymReportEmail);
    _originalEmail = recipients.gymReportEmail;

    // `GymThemeController`, kendi altındaki `_themeStateForGymProvider`
    // stream'i (autoDispose, bu panel ilk açıldığında soğuk başlıyor) henüz
    // ilk snapshot'ını vermediyse sessizce `_fallbackState`e (Egora Mavisi)
    // düşüyor — bu panelin AÇILDIĞI ANDA `activeTheme` okunursa gerçek
    // salon rengi (ör. sarı) henüz gelmemiş olabilir, "orijinal" renk
    // olarak yanlışlıkla mavi kilitlenir. `ThemeController` ise uygulama
    // genelinde zaten `keepAlive` ve ekranda o an GERÇEKTEN render edilen
    // rengi tutuyor (bu ekrana gelindiğinde zaten çözülmüş olmalı) — geri
    // dönüş noktası için asıl güvenilir kaynak bu.
    _originalThemeColor =
        ref.read(themeControllerProvider).valueOrNull?.primary ??
        ref.read(gymThemeControllerProvider.notifier).activeTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final profileState = ref.watch(gymProfileControllerProvider);
    final profileController = ref.read(gymProfileControllerProvider.notifier);
    final recipientsState = ref.watch(reportRecipientsControllerProvider);
    final themeState = ref.watch(gymThemeControllerProvider);
    final themeController = ref.read(gymThemeControllerProvider.notifier);
    final active = themeController.activeTheme;

    // `gyms/{gymId}` dokümanı initState'te henüz Firestore'dan yüklenmemiş
    // olabilir (stream async çözülür) — gerçek veri ilk geldiğinde alanları
    // bir kez doldur. Sonrasında kullanıcı yazarken tekrar üzerine yazmaz.
    if (!_hydratedFromProfile &&
        (profileState.name.isNotEmpty ||
            profileState.address.isNotEmpty ||
            profileState.phone.isNotEmpty)) {
      _hydratedFromProfile = true;
      _nameController.text = profileState.name;
      _addressController.text = '${profileState.address}, ${profileState.city}';
      if (profileState.phone.isNotEmpty) {
        _phoneController.value = PhoneNumber.parse(profileState.phone);
      }
    }

    // `reportEmails` ayrı bir stream'den (`_recipientsForGymProvider`) geldiği
    // için profil verisiyle aynı anda çözülmeyebilir — initState'te
    // `ref.read` ile alınan değer henüz boş olabiliyordu (stream ilk
    // yayınını yapmadan), bu yüzden kaydedilmiş bir e-posta olsa bile alan
    // her zaman boş görünüyordu. Gerçek veri geldiğinde bir kez doldurulur.
    if (!_hydratedFromRecipients && recipientsState.gymReportEmail.isNotEmpty) {
      _hydratedFromRecipients = true;
      _emailController.text = recipientsState.gymReportEmail;
      _originalEmail = recipientsState.gymReportEmail;
    }

    if (_pickedLogoFile == null &&
        profileState.logoUrl.isNotEmpty &&
        _paletteSourceKey != profileState.logoUrl &&
        !_isExtractingPalette) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _extractPaletteFromNetwork(profileState.logoUrl);
      });
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
                  AppBackButton(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.gymsGymInfoTitle),
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
                  AppSpacing.md,
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
                          errorText: _nameError,
                          onChanged: profileController.updateName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoAddressFieldLabel,
                            ),
                          ),
                          controller: _addressController,
                          errorText: _addressError,
                          onChanged: profileController.updateAddress,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppPhoneField(
                          label: ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonTelefonLabel),
                          ),
                          controller: _phoneController,
                          errorText: _phoneError,
                          onChanged: (e164, isValid) => profileController
                              .updatePhone(e164, isValid: isValid),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppCurrencyField(
                          currencyCode: profileState.currency,
                          locale: ref.watch(localeControllerProvider),
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoCurrencyFieldLabel,
                            ),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoLoginReportEmailLabel,
                            ),
                          ),
                          hint: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoGymReportEmailHint,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          errorText: _emailError,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.gymsGymInfoLogoSection),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (_pickedLogoFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            child: Image.file(
                              File(_pickedLogoFile!.path),
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (profileState.logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            child: CachedNetworkImage(
                              imageUrl: profileState.logoUrl,
                              width: 84,
                              height: 84,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInner,
                              ),
                              border: Border.all(color: colors.outlineStrong),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_outlined,
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.gymsGymInfoLogoHelper,
                                  ),
                                ),
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Material(
                                color: colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusInner,
                                ),
                                child: InkWell(
                                  onTap: (_isUploadingLogo || _isSaving)
                                      ? null
                                      : _pickLogo,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusInner,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                    ),
                                    constraints: const BoxConstraints(
                                      minHeight: 40,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _isUploadingLogo
                                          ? ref.watch(
                                              rcTextProvider(
                                                RemoteConfigKeys
                                                    .gymsGymInfoUploadingLabel,
                                              ),
                                            )
                                          : (_pickedLogoFile == null &&
                                                    profileState.logoUrl.isEmpty
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
                                                  )),
                                      style: typography.headingSmall.copyWith(
                                        fontSize: 14,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_logoError != null) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _logoError!,
                                  style: typography.caption.copyWith(
                                    color: colors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsGymInfoThemeColorSection,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                        if (_isExtractingPalette)
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
                        else if (_logoPalette.isNotEmpty)
                          Row(
                            children: [
                              for (final color in _logoPalette)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.md,
                                  ),
                                  child: _ColorDot(
                                    color: color,
                                    selected:
                                        color.toARGB32() ==
                                        (_previewColor ?? active.primary)
                                            .toARGB32(),
                                    onTap: () => _previewColorTap(color),
                                  ),
                                ),
                            ],
                          )
                        else
                          Row(
                            children: [
                              for (final theme in themeState.themes)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.md,
                                  ),
                                  child: _ThemeDot(
                                    theme: theme,
                                    selected:
                                        theme.primary.toARGB32() ==
                                        (_previewColor ?? active.primary)
                                            .toARGB32(),
                                    onTap: () =>
                                        _previewColorTap(theme.primary),
                                  ),
                                ),
                            ],
                          ),
                        if (themeState.errorMessage != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            themeState.errorMessage!,
                            style: typography.bodyMedium.copyWith(
                              color: colors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoThemeColorNote,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            onTap: () => ref
                                .read(panelStackControllerProvider.notifier)
                                .push(const GymThemesPanel()),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ref.watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .gymsGymInfoSeeAllThemesLink,
                                  ),
                                ),
                                style: typography.headingSmall.copyWith(
                                  fontSize: 14,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (recipientsState.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      recipientsState.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
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
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoSavingLabel,
                            ),
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

  @override
  void onPanelHide() {
    if (_previewColor != null) {
      ref
          .read(themeControllerProvider.notifier)
          .setAccentColor(_originalThemeColor);
    }
    super.onPanelHide();
  }

  /// Sadece yerel önizleme + palet çıkarımı yapar — gerçek upload artık
  /// `_save()`e (Kaydet butonuna) bağlı. Önceden burada hemen `_uploadLogo`
  /// çağrılıyordu, yani logo Kaydet'e basılmadan da Storage'a yükleniyor ve
  /// `gyms/{gymId}.logoUrl` hemen güncelleniyordu — kullanıcı "Kaydet"e
  /// basmadan geri dönse bile yeni logo kalıcı oluyordu. Artık Kaydet'e
  /// basılmazsa eski logo geçerliliğini koruyor.
  Future<void> _pickLogo() async {
    final file = await ref.read(gymLogoServiceProvider).pickLogo();
    if (file == null) return;
    setState(() {
      _pickedLogoFile = file;
      _logoError = null;
      _logoPalette = const [];
      _paletteSourceKey = null;
    });
    await _extractPaletteFromFile(file);
  }

  /// `true` döner ise upload başarılı — `_save()` bunu kontrol edip
  /// başarısızsa kaydetmeyi (ve panelden çıkmayı) durdurur.
  Future<bool> _uploadLogo(XFile file) async {
    final gymId = await ref.read(activeGymIdProvider.future);
    if (gymId == null) {
      setState(() => _logoError = _logoUploadFailedError());
      return false;
    }
    setState(() => _isUploadingLogo = true);
    try {
      await ref
          .read(gymLogoServiceProvider)
          .uploadLogo(gymId: gymId, file: file);
      if (!mounted) return false;
      setState(() {
        _isUploadingLogo = false;
        _logoError = null;
      });
      return true;
    } catch (_) {
      if (!mounted) return false;
      setState(() {
        _isUploadingLogo = false;
        _logoError = _logoUploadFailedError();
      });
      return false;
    }
  }

  String _logoUploadFailedError() => ref.read(
    rcTextProvider(RemoteConfigKeys.gymsGymInfoLogoUploadFailedError),
  );

  Future<void> _extractPaletteFromFile(XFile file) async {
    setState(() => _isExtractingPalette = true);
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        FileImage(File(file.path)),
        maximumColorCount: 12,
      );
      if (!mounted) return;
      setState(() {
        _logoPalette = extractGymPaletteColors(generator);
        _isExtractingPalette = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isExtractingPalette = false);
    }
  }

  Future<void> _extractPaletteFromNetwork(String url) async {
    if (_paletteSourceKey == url) return;
    _paletteSourceKey = url;
    setState(() => _isExtractingPalette = true);
    try {
      final generator = await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        maximumColorCount: 12,
      );
      if (!mounted) return;
      setState(() {
        _logoPalette = extractGymPaletteColors(generator);
        _isExtractingPalette = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isExtractingPalette = false);
    }
  }

  void _previewColorTap(Color color) {
    setState(() => _previewColor = color);
    ref.read(themeControllerProvider.notifier).setAccentColor(color);
  }

  Future<void> _saveTheme() async {
    final color = _previewColor;
    if (color == null) return;
    final themeState = ref.read(gymThemeControllerProvider);
    final themeController = ref.read(gymThemeControllerProvider.notifier);
    final matching = themeState.themes
        .where((t) => t.primary.toARGB32() == color.toARGB32())
        .firstOrNull;
    if (matching != null) {
      await themeController.selectTheme(matching.id);
    } else {
      final hex = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
      await themeController.addTheme(
        GymTheme(
          id: 'logo-$hex',
          name: ref.read(
            rcTextProvider(RemoteConfigKeys.gymsGymInfoLogoColorThemeName),
          ),
          primary: color,
          soft: Color.lerp(color, Colors.white, 0.35)!,
          note: ref.read(
            rcTextProvider(RemoteConfigKeys.gymsGymInfoLogoColorThemeNote),
          ),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _previewColor = null);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phoneNumber = _phoneController.value;
    final email = _emailController.text.trim();
    setState(() {
      _nameError = name.isEmpty
          ? ref.read(
              rcTextProvider(RemoteConfigKeys.gymsGymInfoNameRequiredError),
            )
          : null;
      _addressError = address.isEmpty
          ? ref.read(
              rcTextProvider(RemoteConfigKeys.gymsGymInfoAddressRequiredError),
            )
          : null;
      _phoneError = phoneNumber.isValid()
          ? null
          : ref.read(
              rcTextProvider(RemoteConfigKeys.gymsGymInfoPhoneRequiredError),
            );
      // Egoractive Authentication Sistemi §9/§10 — "Login ve rapor e-postası"
      // zorunlu, admin OTP girişinde bununla eşleşen kaydı kullanır.
      _emailError = (!email.contains('@') || email.length < 4)
          ? ref.read(
              rcTextProvider(RemoteConfigKeys.authEmailSetupInvalidEmailError),
            )
          : null;
      _saveErrorMessage = null;
    });
    if (_nameError != null ||
        _addressError != null ||
        _phoneError != null ||
        _emailError != null) {
      return;
    }

    if (email == _originalEmail) {
      await _continueSave();
      return;
    }

    // Egoractive Authentication Sistemi §10 — email değiştiyse direkt
    // kaydedilmez: önce yeni email'e OTP gönderilir, doğrulanınca (bkz.
    // `onVerified`) geri kalan alanlar (ve email'in kendisi, backend
    // tarafında) kaydedilir. Save'e hiç basılmadan geri çıkılırsa hiçbir
    // şey değişmez — bu alanlar zaten sadece local TextEditingController'da.
    setState(() => _isSaving = true);
    try {
      await ref.read(authRepositoryProvider).sendEmailChangeOtp(email);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveErrorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.authOtpGenericError),
        );
      });
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = false);
    ref
        .read(panelStackControllerProvider.notifier)
        .push(
          OtpVerificationPanel(
            purpose: OtpPurpose.emailChange,
            email: email,
            onVerified: () async {
              _originalEmail = email;
              await _continueSave();
            },
          ),
        );
  }

  Future<void> _continueSave() async {
    setState(() => _isSaving = true);
    try {
      final pickedLogo = _pickedLogoFile;
      if (pickedLogo != null) {
        final uploaded = await _uploadLogo(pickedLogo);
        if (!uploaded) {
          if (mounted) setState(() => _isSaving = false);
          return;
        }
      }
      await ref.read(gymProfileControllerProvider.notifier).save();
      if (_previewColor != null) await _saveTheme();
      await ref
          .read(reportRecipientsControllerProvider.notifier)
          .save(ReportRecipients(gymReportEmail: _emailController.text.trim()));
      if (!mounted) return;
      final recipientsError = ref
          .read(reportRecipientsControllerProvider)
          .errorMessage;
      if (recipientsError != null) {
        setState(() {
          _isSaving = false;
          _saveErrorMessage = recipientsError;
        });
        return;
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveErrorMessage = ref.read(
          rcTextProvider(RemoteConfigKeys.gymsGymInfoSaveFailedError),
        );
      });
      return;
    }
    if (!mounted) return;
    ref.read(panelStackControllerProvider.notifier).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot({
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

/// [_ThemeDot] ile aynı görünüm, ama hazır bir [GymTheme] presetine değil
/// logodan çıkarılan ham bir [Color]'a bağlı (palette_generator önerisi) —
/// bkz. [GymSetupPanel]'in aynı amaçla kullandığı `_ColorSwatch`.
class _ColorDot extends StatelessWidget {
  const _ColorDot({
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
