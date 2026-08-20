import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/theme_palette.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/gym_theme_controller.dart';
import '../../domain/gym_theme.dart';

/// Admin · Tema Ekle — paletten seç veya renk kodu gir. Salon logosunun
/// arka planda gösterilip gösterilmeyeceği artık sadece Temalar
/// (`GymThemesPanel`) ekranında ayarlanıyor — burada tekrarlanmıyor.
class AddGymThemePanel extends BasePanel {
  const AddGymThemePanel({super.key});

  @override
  ConsumerState<AddGymThemePanel> createState() => _AddGymThemePanelState();
}

class _AddGymThemePanelState extends BasePanelState<AddGymThemePanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _hexController;
  Color _selectedColor = AppThemePalette.colors.first;
  bool _isSaving = false;
  String? _hexError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _hexController = TextEditingController(text: _hexOf(_selectedColor));
  }

  static String _hexOf(Color color) =>
      color.toARGB32().toRadixString(16).substring(2).toUpperCase();

  void _onHexChanged(String value) {
    final normalized = value.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(normalized)) {
      setState(
        () => _hexError = ref.read(
          rcTextProvider(RemoteConfigKeys.gymsAddThemeInvalidHexError),
        ),
      );
      return;
    }
    setState(() {
      _hexError = null;
      _selectedColor = Color(int.parse('FF$normalized', radix: 16));
    });
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
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.gymsAddThemeTitle),
                      ),
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
                      ref.watch(rcTextProvider(RemoteConfigKeys.commonVazgec)),
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
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAddThemeNameFieldLabel,
                            ),
                          ),
                          controller: _nameController,
                          hint: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAddThemeNameFieldHint,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAddThemePaletteLabel,
                            ),
                          ),
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
                              onTap: () => setState(() {
                                _selectedColor = color;
                                _hexError = null;
                                _hexController.text = _hexOf(color);
                              }),
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
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAddThemeColorCodeLabel,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              margin: const EdgeInsets.only(top: AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: _selectedColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: AppTextField(
                                label: null,
                                controller: _hexController,
                                prefixText: '#',
                                errorText: _hexError,
                                onChanged: _onHexChanged,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAddThemeColorHelper,
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
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsAddThemePreviewSection,
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
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .gymsThemePreviewRemainingSessionsLabel,
                                        ),
                                      ),
                                      style: typography.headingSmall.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .gymsThemePreviewNextSessionLabel,
                                        ),
                                      ),
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
                              ref.watch(
                                rcTextProvider(RemoteConfigKeys.commonGelicem),
                              ),
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
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoSavingLabel,
                            ),
                          )
                        : ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsAddThemeSubmitButton,
                            ),
                          ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final name = _nameController.text.trim().isEmpty
                                ? ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys.gymsAddThemeDefaultName,
                                    ),
                                  )
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
                                note: ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .gymsAddThemeCustomColorNote,
                                  ),
                                ),
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
    _hexController.dispose();
    super.dispose();
  }
}
