import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/utils/gym_logo_image.dart';
import '../../../../shared/utils/phone_number_formatter.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
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
  late final TextEditingController _phoneController;
  late final TextEditingController _gymReportEmailController;
  late final TextEditingController _accountingReportEmailController;

  bool _isSaving = false;
  bool _hydratedFromProfile = false;
  String? _nameError;
  String? _addressError;
  String? _phoneError;
  String? _saveErrorMessage;

  XFile? _pickedLogoFile;
  bool _isUploadingLogo = false;
  String? _logoError;

  List<Color> _logoPalette = const [];
  bool _isExtractingPalette = false;
  String? _paletteSourceKey;

  Color? _previewColor;
  late final GymTheme _originalTheme;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(gymProfileControllerProvider);
    _nameController = TextEditingController(text: profile.name);
    _addressController = TextEditingController(
      text: '${profile.address}, ${profile.city}',
    );
    _phoneController = TextEditingController(
      text: formatTrPhoneDigits(profile.phone),
    );

    final recipients = ref.read(reportRecipientsControllerProvider);
    _gymReportEmailController = TextEditingController(
      text: recipients.gymReportEmail,
    );
    _accountingReportEmailController = TextEditingController(
      text: recipients.accountingReportEmail,
    );

    _originalTheme = ref.read(gymThemeControllerProvider.notifier).activeTheme;
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
      _phoneController.text = formatTrPhoneDigits(profileState.phone);
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
                    'Salon bilgileri',
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
                          label: 'Salon adı',
                          controller: _nameController,
                          errorText: _nameError,
                          onChanged: profileController.updateName,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Adres',
                          controller: _addressController,
                          errorText: _addressError,
                          onChanged: profileController.updateAddress,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Telefon',
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                          inputFormatters: [TrPhoneNumberInputFormatter()],
                          errorText: _phoneError,
                          onChanged: profileController.updatePhone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'LOGO',
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_pickedLogoFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            child: Image.file(
                              File(_pickedLogoFile!.path),
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (profileState.logoUrl.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            child: Image.network(
                              profileState.logoUrl,
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          Container(
                            width: 72,
                            height: 72,
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
                                'Kare, en az 512×512 px PNG yükleyin.',
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
                                  onTap: _isUploadingLogo ? null : _pickLogo,
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
                                          ? 'Yükleniyor…'
                                          : (_pickedLogoFile == null &&
                                                    profileState.logoUrl.isEmpty
                                                ? 'Logo seç'
                                                : 'Logoyu değiştir'),
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
                    'TEMA RENGİ',
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
                                'Logodan renkler çıkarılıyor…',
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
                        const SizedBox(height: AppSpacing.md),
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          child: InkWell(
                            onTap: _previewColor == null ? null : _saveTheme,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              decoration: BoxDecoration(
                                color: _previewColor == null
                                    ? active.primary.withValues(alpha: 0.4)
                                    : active.primary,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusInner,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Kaydet',
                                style: typography.headingSmall.copyWith(
                                  fontSize: 15,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Seçtiğiniz renk üyelerin uygulamasında da birincil renk olur; koyu zemin ve durum renkleri değişmez.',
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
                                'Tüm temaları gör ›',
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
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'RAPOR E-POSTALARI',
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
                        Text(
                          'Haftalık salon ve muhasebe özeti bu adreslere e-posta ile gönderilir.',
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Salon raporu e-postası',
                          hint: 'admin@stüdyo.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _gymReportEmailController,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Muhasebe raporu e-postası',
                          hint: 'muhasebe@stüdyo.com',
                          keyboardType: TextInputType.emailAddress,
                          controller: _accountingReportEmailController,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        if (recipientsState.errorMessage != null) ...[
                          Text(
                            recipientsState.errorMessage!,
                            style: typography.bodyMedium.copyWith(
                              color: colors.error,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            onTap: recipientsState.isSaving
                                ? null
                                : () => ref
                                      .read(
                                        reportRecipientsControllerProvider
                                            .notifier,
                                      )
                                      .save(
                                        ReportRecipients(
                                          gymReportEmail:
                                              _gymReportEmailController.text
                                                  .trim(),
                                          accountingReportEmail:
                                              _accountingReportEmailController
                                                  .text
                                                  .trim(),
                                        ),
                                      ),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 44),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                recipientsState.isSaving
                                    ? 'Kaydediliyor…'
                                    : 'Rapor e-postalarını kaydet',
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
                    label: _isSaving ? 'Kaydediliyor…' : 'Kaydet',
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
          .setAccentColor(_originalTheme.primary);
    }
    super.onPanelHide();
  }

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
    await _uploadLogo(file);
  }

  Future<void> _uploadLogo(XFile file) async {
    final gymId = await ref.read(activeGymIdProvider.future);
    if (gymId == null) {
      setState(() => _logoError = 'Logo yüklenemedi, tekrar dene.');
      return;
    }
    setState(() => _isUploadingLogo = true);
    try {
      await ref
          .read(gymLogoServiceProvider)
          .uploadLogo(gymId: gymId, file: file);
      if (!mounted) return;
      setState(() => _isUploadingLogo = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isUploadingLogo = false;
        _logoError = 'Logo yüklenemedi, tekrar dene.';
      });
    }
  }

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
          name: 'Logo rengi',
          primary: color,
          soft: Color.lerp(color, Colors.white, 0.35)!,
          note: 'Logonuzdan çıkarıldı',
        ),
      );
    }
    if (!mounted) return;
    setState(() => _previewColor = null);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final phone = _phoneController.text.trim();
    setState(() {
      _nameError = name.isEmpty ? 'Salon adı boş olamaz.' : null;
      _addressError = address.isEmpty ? 'Adres boş olamaz.' : null;
      _phoneError = phone.isEmpty ? 'Telefon boş olamaz.' : null;
      _saveErrorMessage = null;
    });
    if (_nameError != null || _addressError != null || _phoneError != null) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(gymProfileControllerProvider.notifier).save();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveErrorMessage = 'Salon bilgileri kaydedilemedi, tekrar dene.';
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
    _gymReportEmailController.dispose();
    _accountingReportEmailController.dispose();
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
