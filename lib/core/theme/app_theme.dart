import 'package:flutter/material.dart';

import 'app_color_scheme.dart';
import 'app_typography.dart';

/// [AppColorScheme] + [AppTypography]'yi tek bir `ThemeData`'ya dönüştürür.
///
/// Örtüşen roller (primary/secondary/surface/error vb.) Flutter'ın kendi
/// `ColorScheme`'ine yazılır — widget'lar `Theme.of(context).colorScheme.X`
/// kullanabilir. Bu modele özgü ek roller (surfaceRaised, warning/success
/// container'ları, outline seviyeleri) `ThemeData.extensions` üzerinden
/// `Theme.of(context).extension<AppColorScheme>()` ile erişilir — CLAUDE.md
/// §2.4'teki "ya da proje AppTheme extension'ı üzerinden" kuralı budur.
abstract final class AppTheme {
  static ThemeData build({
    required AppColorScheme colors,
    required AppTypography typography,
  }) {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      surface: colors.surface,
      onSurface: colors.onSurface,
      error: colors.error,
      onError: Colors.white,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      outline: colors.outline,
      outlineVariant: colors.outlineStrong,
      surfaceContainerHighest: colors.surfaceRaised,
    );

    final textTheme = TextTheme(
      headlineLarge: typography.headingLarge.copyWith(color: colors.onSurface),
      headlineMedium: typography.headingMedium.copyWith(color: colors.onSurface),
      headlineSmall: typography.headingSmall.copyWith(color: colors.onSurface),
      titleLarge: typography.headingMedium.copyWith(color: colors.onSurface),
      titleMedium: typography.headingSmall.copyWith(color: colors.onSurface),
      bodyLarge: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant),
      bodyMedium: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
      labelLarge: typography.dataSmall.copyWith(color: colors.onSurface),
      labelMedium: typography.caption.copyWith(color: colors.onSurfaceMuted),
      labelSmall: typography.caption.copyWith(color: colors.onSurfaceMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      textTheme: textTheme,
      extensions: [colors, typography],
    );
  }
}

extension AppThemeContext on BuildContext {
  /// Kısayol: `Theme.of(context).extension<AppColorScheme>()!`.
  AppColorScheme get appColors => Theme.of(this).extension<AppColorScheme>()!;

  /// Kısayol: `Theme.of(context).extension<AppTypography>()!`.
  AppTypography get appTypography => Theme.of(this).extension<AppTypography>()!;
}
