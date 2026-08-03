import 'package:flutter/material.dart';

/// Egoractive'in tipografi rolleri (CLAUDE.md §2.4) — başlık, gövde ve
/// sayısal veri (tabular) için ayrı bir stil ailesi.
///
/// Stiller renksizdir; renk [AppTheme.build] içinde [AppColorScheme]'den
/// uygulanır. Panel'ler `Theme.of(context).textTheme.X` üzerinden okur.
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  const AppTypography({
    required this.headingLarge,
    required this.headingMedium,
    required this.headingSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.caption,
    required this.dataLarge,
    required this.dataMedium,
    required this.dataSmall,
  });

  factory AppTypography.standard() => const AppTypography(
        // Panel/sayfa başlığı — örn. "Takvim".
        headingLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 28,
          height: 1.1,
          letterSpacing: -0.02,
        ),
        // Bölüm/kart başlığı — örn. "Merhaba Ayşe".
        headingMedium: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 19,
          height: 1.2,
          letterSpacing: -0.01,
        ),
        // Liste/kart öğesi başlığı — örn. "Birebir · 18:30".
        headingSmall: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 17,
          height: 1.25,
          letterSpacing: -0.01,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'IBM Plex Sans',
          fontWeight: FontWeight.w400,
          fontSize: 16,
          height: 1.55,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'IBM Plex Sans',
          fontWeight: FontWeight.w400,
          fontSize: 14,
          height: 1.5,
        ),
        caption: TextStyle(
          fontFamily: 'IBM Plex Sans',
          fontWeight: FontWeight.w500,
          fontSize: 13,
          height: 1.4,
        ),
        // Kalan ders, tutar, ölçüm gibi büyük tekil veriler.
        dataLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 34,
          height: 1,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        dataMedium: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 22,
          height: 1,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        // Satır içi veri — örn. "6 ders · ₺14.400 · 74,5 cm".
        dataSmall: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          height: 1.3,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      );

  final TextStyle headingLarge;
  final TextStyle headingMedium;
  final TextStyle headingSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle caption;
  final TextStyle dataLarge;
  final TextStyle dataMedium;
  final TextStyle dataSmall;

  @override
  AppTypography copyWith({
    TextStyle? headingLarge,
    TextStyle? headingMedium,
    TextStyle? headingSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? caption,
    TextStyle? dataLarge,
    TextStyle? dataMedium,
    TextStyle? dataSmall,
  }) {
    return AppTypography(
      headingLarge: headingLarge ?? this.headingLarge,
      headingMedium: headingMedium ?? this.headingMedium,
      headingSmall: headingSmall ?? this.headingSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      caption: caption ?? this.caption,
      dataLarge: dataLarge ?? this.dataLarge,
      dataMedium: dataMedium ?? this.dataMedium,
      dataSmall: dataSmall ?? this.dataSmall,
    );
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(
      headingLarge: TextStyle.lerp(headingLarge, other.headingLarge, t)!,
      headingMedium: TextStyle.lerp(headingMedium, other.headingMedium, t)!,
      headingSmall: TextStyle.lerp(headingSmall, other.headingSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      dataLarge: TextStyle.lerp(dataLarge, other.dataLarge, t)!,
      dataMedium: TextStyle.lerp(dataMedium, other.dataMedium, t)!,
      dataSmall: TextStyle.lerp(dataSmall, other.dataSmall, t)!,
    );
  }
}
