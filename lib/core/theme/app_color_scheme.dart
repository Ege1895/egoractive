import 'package:flutter/material.dart';

/// Salon bazlı temanın taşıdığı semantic renk rolleri (CLAUDE.md §2.4).
///
/// `ThemeController` bu modeli `gyms/{gymId}.themeColors` alanından üretip
/// [AppTheme.build] ile `ThemeData`'ya dönüştürür. Widget'lar rengi asla
/// literal `Color(0xFF...)` olarak değil, `Theme.of(context).colorScheme.X`
/// (örtüşen roller için) ya da `Theme.of(context).extension<AppColorScheme>()`
/// (bu modele özgü roller için) üzerinden okur.
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onSurfaceMuted,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.error,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.outline,
    required this.outlineStrong,
  });

  /// Egora mavisi + üç katlı koyu zemin — salon teması yoksa kullanılan taban.
  factory AppColorScheme.defaultScheme() => const AppColorScheme(
        primary: Color(0xFF05A6FA),
        onPrimary: Color(0xFF04121C),
        primaryContainer: Color(0x2405A6FA),
        onPrimaryContainer: Color(0xFF48C2FF),
        secondary: Color(0xFF48C2FF),
        onSecondary: Color(0xFF04121C),
        background: Color(0xFF0A0E13),
        surface: Color(0xFF141B23),
        surfaceRaised: Color(0xFF1B242E),
        onSurface: Color(0xFFF2F7FB),
        onSurfaceVariant: Color(0xFFC9D6E2),
        onSurfaceMuted: Color(0xFF8496A8),
        success: Color(0xFF2ED393),
        successContainer: Color(0x1F2ED393),
        onSuccessContainer: Color(0xFF7FE8C4),
        warning: Color(0xFFFFB020),
        warningContainer: Color(0xFF241C10),
        onWarningContainer: Color(0xFFFFC963),
        error: Color(0xFFFF5F52),
        errorContainer: Color(0x1FFF5F52),
        onErrorContainer: Color(0xFFFF9B92),
        outline: Color(0x12FFFFFF),
        outlineStrong: Color(0x1AFFFFFF),
      );

  /// Dolu birincil buton zemini.
  final Color primary;

  /// Dolu birincil buton üzerindeki metin/ikon.
  final Color onPrimary;

  /// Yumuşatılmış mavi zemin (rozet, seçili durum vb.) — "mavi bütçesi" kuralı.
  final Color primaryContainer;

  /// [primaryContainer] üzerindeki metin/ikon.
  final Color onPrimaryContainer;

  final Color secondary;
  final Color onSecondary;

  /// En dip zemin (Scaffold arka planı).
  final Color background;

  /// Kart zemini.
  final Color surface;

  /// Kart içi blok zemini (üçüncü katman).
  final Color surfaceRaised;

  /// Başlık metni.
  final Color onSurface;

  /// Gövde metni.
  final Color onSurfaceVariant;

  /// İkincil/caption metni.
  final Color onSurfaceMuted;

  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color error;
  final Color errorContainer;
  final Color onErrorContainer;

  /// Varsayılan temayı [primary] vurgu rengine göre türetir — koyu zemin ve
  /// durum renkleri (success/warning/error) sabit kalır, sadece vurgu ve
  /// ondan türeyen roller değişir. `ThemeController.setAccentColor` ve
  /// Firestore `gyms/{gymId}.themeColors` dinleyicisi bunu paylaşır.
  factory AppColorScheme.withAccent(Color primary) {
    return AppColorScheme.defaultScheme().copyWith(
      primary: primary,
      primaryContainer: primary.withValues(alpha: 0.14),
      onPrimaryContainer: Color.lerp(primary, Colors.white, 0.35)!,
      secondary: Color.lerp(primary, Colors.white, 0.25)!,
    );
  }

  /// Kart kenarlığı.
  final Color outline;

  /// Daha belirgin kenarlık (avatar halkası, ikon buton çerçevesi).
  final Color outlineStrong;

  @override
  AppColorScheme copyWith({
    Color? primary,
    Color? onPrimary,
    Color? primaryContainer,
    Color? onPrimaryContainer,
    Color? secondary,
    Color? onSecondary,
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? onSurfaceMuted,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? error,
    Color? errorContainer,
    Color? onErrorContainer,
    Color? outline,
    Color? outlineStrong,
  }) {
    return AppColorScheme(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      onPrimaryContainer: onPrimaryContainer ?? this.onPrimaryContainer,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      onSurfaceMuted: onSurfaceMuted ?? this.onSurfaceMuted,
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      error: error ?? this.error,
      errorContainer: errorContainer ?? this.errorContainer,
      onErrorContainer: onErrorContainer ?? this.onErrorContainer,
      outline: outline ?? this.outline,
      outlineStrong: outlineStrong ?? this.outlineStrong,
    );
  }

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      onPrimaryContainer: Color.lerp(onPrimaryContainer, other.onPrimaryContainer, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      onSurfaceMuted: Color.lerp(onSurfaceMuted, other.onSurfaceMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorContainer: Color.lerp(errorContainer, other.errorContainer, t)!,
      onErrorContainer: Color.lerp(onErrorContainer, other.onErrorContainer, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      outlineStrong: Color.lerp(outlineStrong, other.outlineStrong, t)!,
    );
  }
}
