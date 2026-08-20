import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// CLAUDE.md §2.4 bileşen kütüphanesi — surfaceRaised zeminli, kenarlıksız
/// (odaklanınca primary halka) metin girişi.
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.onChanged,
    this.inputFormatters,
    this.prefixText,
    this.minLines,
    this.maxLines = 1,
    this.scrollController,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  /// `maxLines` 1'den büyükse (çok satırlı not alanı gibi) `minLines`'tan
  /// başlayıp `maxLines`'a kadar büyür, sonrasında TextField'ın kendi iç
  /// scroll'una düşer.
  final int? minLines;
  final int? maxLines;

  /// Çok satırlı alanı sarmalayan bir [Scrollbar]'ın (ör. `thumbVisibility:
  /// true`) hedef alacağı controller — verilmezse TextField kendi iç
  /// scroll'unu PrimaryScrollController olmadan yönetir.
  final ScrollController? scrollController;

  /// Girdinin başında sabit gösterilen, düzenlenemeyen metin (ör. "+90 ").
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(AppSpacing.radiusInner);

    return TextField(
      controller: controller,
      scrollController: scrollController,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      minLines: minLines,
      maxLines: maxLines,
      style: context.appTypography.bodyLarge.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines != 1,
        hintText: hint,
        errorText: errorText,
        prefixText: prefixText,
        prefixStyle: context.appTypography.bodyLarge.copyWith(
          color: colors.onSurfaceVariant,
        ),
        hintStyle: context.appTypography.bodyLarge.copyWith(
          color: colors.onSurfaceMuted,
        ),
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
