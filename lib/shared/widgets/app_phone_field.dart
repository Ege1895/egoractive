import 'package:flutter/material.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// F8-1 — global telefon numarası desteği. `AppTextField`'ın görsel dilini
/// (surfaceRaised zemin, kenarlıksız/odakta primary halka) `PhoneFormField`
/// üzerine taşıyan ortak bileşen. Varsayılan ülke TR; `onChangedE164`
/// numara E.164 formatında (`+905324187605`) değiştikçe tetiklenir.
///
/// Henüz hiçbir ekrana bağlı değil — F8-2/F8-4'te auth ve iletişim telefon
/// formlarına geçirilecek.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    this.controller,
    this.label,
    this.errorText,
    this.enabled = true,
    this.onChangedE164,
    super.key,
  });

  final PhoneController? controller;
  final String? label;
  final String? errorText;
  final bool enabled;

  /// Numara değiştikçe E.164 (`PhoneNumber.international`) ile tetiklenir.
  final ValueChanged<String>? onChangedE164;

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
      onChanged: onChangedE164 == null
          ? null
          : (phoneNumber) => onChangedE164!(phoneNumber.international),
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
