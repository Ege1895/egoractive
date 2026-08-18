import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../reports/controller/report_recipients_controller.dart';
import '../../../reports/domain/report_recipients.dart';
import '../../controller/gym_profile_controller.dart';
import '../../controller/gym_theme_controller.dart';
import '../../domain/gym_theme.dart';
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

  @override
  void initState() {
    super.initState();
    final profile = ref.read(gymProfileControllerProvider);
    _nameController = TextEditingController(text: profile.name);
    _addressController = TextEditingController(
      text: '${profile.address}, ${profile.city}',
    );
    _phoneController = TextEditingController(text: profile.phone);

    final recipients = ref.read(reportRecipientsControllerProvider);
    _gymReportEmailController = TextEditingController(
      text: recipients.gymReportEmail,
    );
    _accountingReportEmailController = TextEditingController(
      text: recipients.accountingReportEmail,
    );
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
      _phoneController.text = profileState.phone;
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
                      children: [
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
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 40,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceRaised,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusInner,
                                  ),
                                ),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Logoyu değiştir',
                                  style: typography.headingSmall.copyWith(
                                    fontSize: 14,
                                    color: colors.onSurfaceMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Logo değişikliği bu ekrandan henüz yapılamıyor.',
                                style: typography.caption.copyWith(
                                  color: colors.onSurfaceMuted,
                                  fontSize: 12,
                                ),
                              ),
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
                                      theme.id == themeState.activeThemeId,
                                  onTap: () =>
                                      themeController.selectTheme(theme.id),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Önizleme',
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                    Text(
                                      'Birincil buton',
                                      style: typography.headingSmall.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.lg,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 44,
                                ),
                                decoration: BoxDecoration(
                                  color: active.primary,
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
                            ],
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
