import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/theme_palette.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/gym_theme_controller.dart';
import '../../domain/gym_theme.dart';

/// Admin · Tema Ekle — paletten seç veya renk kodu gir, salon logosu
/// kullanılsın mı seçeneği.
class AddGymThemePanel extends BasePanel {
  const AddGymThemePanel({super.key});

  @override
  ConsumerState<AddGymThemePanel> createState() => _AddGymThemePanelState();
}

class _AddGymThemePanelState extends BasePanelState<AddGymThemePanel> {
  late final TextEditingController _nameController;
  late bool _useGymLogo;
  Color _selectedColor = AppThemePalette.colors.first;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _useGymLogo = ref.read(gymThemeControllerProvider).watermarkEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final themeState = ref.watch(gymThemeControllerProvider);
    final controller = ref.read(gymThemeControllerProvider.notifier);

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
                      'Tema ekle',
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
                      'Vazgeç',
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
                          label: 'Tema adı',
                          controller: _nameController,
                          hint: 'Vira İmza',
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Palet',
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: AppThemePalette.colors.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 6,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                              ),
                          itemBuilder: (context, index) {
                            final color = AppThemePalette.colors[index];
                            final selected = color == _selectedColor;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? colors.onSurface
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: selected
                                    ? Text(
                                        '✓',
                                        style: typography.headingSmall.copyWith(
                                          fontSize: 13,
                                          color: colors.background,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Renk kodu',
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          constraints: const BoxConstraints(minHeight: 48),
                          decoration: BoxDecoration(
                            color: colors.surfaceRaised,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                                  style: typography.dataMedium.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Paletten seçin ya da kendi HEX kodunuzu yazın.',
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
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
                          'Salon logosu kullanılsın mı?',
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Açıkken üye ve antrenör ekranlarının arkasında %25 opaklıkla görünür.',
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _LogoRadioRow(
                          label: 'Evet, logoyu kullan',
                          selected: _useGymLogo,
                          onTap: () => setState(() => _useGymLogo = true),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _LogoRadioRow(
                          label: 'Hayır, düz zemin',
                          selected: !_useGymLogo,
                          onTap: () => setState(() => _useGymLogo = false),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'ÖNİZLEME',
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
                      children: [
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
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor,
                                    width: 3,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '6',
                                  style: typography.dataMedium.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kalan dersin: 6',
                                      style: typography.headingSmall.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      'Sıradaki ders 3 Ağustos 18:30',
                                      style: typography.bodyMedium.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Material(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.center,
                            child: Text(
                              'Gelicem',
                              style: typography.headingSmall.copyWith(
                                fontSize: 15,
                                color: colors.onPrimary,
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
                  if (themeState.errorMessage != null) ...[
                    Text(
                      themeState.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _isSaving
                        ? 'Kaydediliyor…'
                        : 'Temayı kaydet ve uygula',
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final name = _nameController.text.trim().isEmpty
                                ? 'Yeni Tema'
                                : _nameController.text.trim();
                            setState(() => _isSaving = true);
                            await controller.addTheme(
                              GymTheme(
                                id: '${name.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}',
                                name: name,
                                primary: _selectedColor,
                                soft: Color.lerp(
                                  _selectedColor,
                                  Colors.white,
                                  0.35,
                                )!,
                                note: _useGymLogo
                                    ? 'Salon logosu açık'
                                    : 'Düz zemin',
                              ),
                            );
                            if (!mounted) return;
                            // addTheme başarısız olursa gymThemeControllerProvider.errorMessage
                            // dolu kalır — bu durumda panelde kalıp göstermeliyiz.
                            if (ref
                                    .read(gymThemeControllerProvider)
                                    .errorMessage !=
                                null) {
                              setState(() => _isSaving = false);
                              return;
                            }
                            if (_useGymLogo !=
                                ref
                                    .read(gymThemeControllerProvider)
                                    .watermarkEnabled) {
                              await controller.toggleWatermark();
                            }
                            if (!mounted) return;
                            if (ref
                                    .read(gymThemeControllerProvider)
                                    .errorMessage !=
                                null) {
                              setState(() => _isSaving = false);
                              return;
                            }
                            ref
                                .read(panelStackControllerProvider.notifier)
                                .pop();
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
    super.dispose();
  }
}

class _LogoRadioRow extends StatelessWidget {
  const _LogoRadioRow({
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
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
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: typography.headingSmall.copyWith(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
