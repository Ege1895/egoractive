import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// F8-1/F8-2 — global telefon numarası desteği. `AppTextField`'ın görsel
/// dilini (surfaceRaised zemin, kenarlıksız/odakta primary halka)
/// `PhoneFormField` üzerine taşıyan ortak bileşen. Varsayılan ülke TR;
/// `onChanged` numara değiştikçe E.164 (`+905324187605`) + bölgesel
/// doğrulama sonucuyla (`PhoneNumber.isValid()`) tetiklenir.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    this.controller,
    this.label,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    super.key,
  });

  final PhoneController? controller;
  final String? label;
  final String? errorText;
  final bool enabled;

  /// Numara değiştikçe E.164 (`PhoneNumber.international`) ve o numaranın
  /// seçili ülke için geçerli olup olmadığıyla (`PhoneNumber.isValid()`)
  /// tetiklenir.
  final void Function(String e164, bool isValid)? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final radius = BorderRadius.circular(AppSpacing.radiusInner);

    return PhoneFormField(
      controller: controller,
      initialValue: controller == null ? PhoneNumber.parse('+90') : null,
      enabled: enabled,
      countrySelectorNavigator: const CountrySelectorNavigator.bottomSheet(),
      countryButtonStyle: const CountryButtonStyle(
        showDialCode: true,
        showIsoCode: false,
      ),
      style: typography.bodyLarge.copyWith(color: colors.onSurface),
      onChanged: onChanged == null
          ? null
          : (phoneNumber) =>
                onChanged!(phoneNumber.international, phoneNumber.isValid()),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: typography.bodyLarge.copyWith(
          color: colors.onSurfaceVariant,
        ),
        hintStyle: typography.bodyLarge.copyWith(color: colors.onSurfaceMuted),
        filled: true,
        fillColor: colors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
      ),
    );
  }
}
