import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, text }

/// CLAUDE.md §2.4 bileşen kütüphanesi — dolu birincil, dolu ikincil ve
/// metin buton varyantları. Rengi her zaman `context.appColors`'tan okur.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// true ise mevcut genişliği doldurur (alt aksiyon butonları için varsayılan).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textStyle = context.appTypography.headingSmall.copyWith(fontSize: 15);
    final disabled = onPressed == null;

    final (Color background, Color foreground) = switch (variant) {
      AppButtonVariant.primary => (
          disabled ? colors.surfaceRaised : colors.primary,
          disabled ? colors.onSurfaceMuted : colors.onPrimary,
        ),
      AppButtonVariant.secondary => (
          colors.surfaceRaised,
          disabled ? colors.onSurfaceMuted : colors.onSurfaceVariant,
        ),
      AppButtonVariant.text => (
          Colors.transparent,
          disabled ? colors.onSurfaceMuted : colors.primary,
        ),
    };

    final child = Container(
      constraints: const BoxConstraints(minHeight: AppSpacing.primaryActionHeight),
      width: expand ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      ),
      alignment: Alignment.center,
      child: Text(label, style: textStyle.copyWith(color: foreground)),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: child,
      ),
    );
  }
}
