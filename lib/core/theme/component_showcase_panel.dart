// F1-5 kabul kriteri: "Storybook/widgetbook benzeri demo ekranında tüm
// bileşenler görüntülenebiliyor". Gerçek panel modülleri devreye girdikçe
// bu ekran geliştirici aracı olarak kalabilir ya da kaldırılabilir.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_spacing.dart';
import '../money/app_money_formatter.dart';
import '../panels/base_panel.dart';
import '../theme/app_theme.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_loading_indicator.dart';
import '../../shared/widgets/app_phone_field.dart';
import '../../shared/widgets/app_text_field.dart';

class ComponentShowcasePanel extends BasePanel {
  const ComponentShowcasePanel({super.key});

  @override
  ConsumerState<ComponentShowcasePanel> createState() =>
      _ComponentShowcasePanelState();
}

class _ComponentShowcasePanelState
    extends BasePanelState<ComponentShowcasePanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          children: [
            Text(
              'Bileşen Kütüphanesi',
              style: typography.headingLarge.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Renkler',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _Swatch('primary', colors.primary),
                _Swatch('background', colors.background),
                _Swatch('surface', colors.surface),
                _Swatch('surfaceRaised', colors.surfaceRaised),
                _Swatch('success', colors.success),
                _Swatch('warning', colors.warning),
                _Swatch('error', colors.error),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'AppButton',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(label: 'Kaydet', onPressed: () {}),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Gelmeyeceğim',
              variant: AppButtonVariant.secondary,
              onPressed: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(label: 'Devre dışı', onPressed: null),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: 'Detay',
                variant: AppButtonVariant.text,
                expand: false,
                onPressed: () {},
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'AppTextField',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            const AppTextField(
              label: 'Telefon numarası',
              hint: '05XX XXX XX XX',
            ),
            const SizedBox(height: AppSpacing.sm),
            const AppTextField(
              label: 'E-posta',
              errorText: 'Geçerli bir e-posta girin',
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'AppPhoneField',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            const AppPhoneField(label: 'Telefon numarası'),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'AppMoneyFormatter',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'TRY/tr: ${formatMoney(50000, 'TRY', 'tr')}   '
              'USD/en: ${formatMoney(50000, 'USD', 'en')}   '
              'EUR/en: ${formatMoney(50000, 'EUR', 'en')}',
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Tutar (TR)',
              hint: '50.000',
              keyboardType: TextInputType.number,
              inputFormatters: [AppMoneyInputFormatter(locale: 'tr')],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'AppCard',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Text(
                'Kart içeriği — gölge yok, hiyerarşiyi katman ve kenarlık taşır.',
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'AppLoadingIndicator',
              style: typography.headingMedium.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),
            const AppLoadingIndicator(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            border: Border.all(color: colors.outlineStrong),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: context.appTypography.caption.copyWith(
            color: colors.onSurfaceMuted,
          ),
        ),
      ],
    );
  }
}
