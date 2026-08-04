import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_color_scheme.dart';

part 'theme_controller.g.dart';

/// Salon bazlı dinamik tema (CLAUDE.md §2.4) — aktif salonun tema rengini
/// tutar. Faz 2+'da `gyms/{gymId}.themeColors`'tan yüklenecek; şimdilik
/// `modules/gyms` içindeki GymThemeController mock seçimle burayı günceller.
@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  AppColorScheme build() => AppColorScheme.defaultScheme();

  /// Koyu zemin ve durum renkleri (success/warning/error) sabit kalır —
  /// yalnızca vurgu (primary) rengi ve ondan türeyen roller değişir.
  void setAccentColor(Color primary) {
    state = state.copyWith(
      primary: primary,
      primaryContainer: primary.withValues(alpha: 0.14),
      onPrimaryContainer: Color.lerp(primary, Colors.white, 0.35)!,
      secondary: Color.lerp(primary, Colors.white, 0.25)!,
    );
  }
}
