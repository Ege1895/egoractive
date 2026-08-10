import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/gym_theme.dart';
import '../repository/gym_theme_repository.dart';

part 'gym_theme_controller.g.dart';

const _fallbackState = GymThemeState(
  activeThemeId: 'egora-mavisi',
  themes: [
    GymTheme(id: 'egora-mavisi', name: 'Egora Mavisi', primary: Color(0xFF05A6FA), soft: Color(0xFF48C2FF), note: 'Varsayılan tema'),
    GymTheme(id: 'turuncu-enerji', name: 'Turuncu Enerji', primary: Color(0xFFFF8A3D), soft: Color(0xFFFFB27A), note: 'Sıcak, enerjik vurgu'),
    GymTheme(id: 'yesil-doga', name: 'Yeşil Doğa', primary: Color(0xFF2ED393), soft: Color(0xFF7FE8C4), note: 'Sakin, doğal vurgu'),
  ],
);

@riverpod
Stream<GymThemeState> _themeStateForGym(_ThemeStateForGymRef ref, String gymId) {
  return ref.watch(gymThemeRepositoryProvider).watchState(gymId);
}

/// F4-6 — `gyms/{gymId}.themeColors`/`themePresets`, `ThemeController`
/// (F1-6) tarafından zaten stream olarak dinleniyor; buradaki yazmalar
/// sayesinde bir değişiklik, uygulamayı yeniden başlatmadan tüm aktif
/// client'larda anlık yansır (kabul kriteri).
@riverpod
class GymThemeController extends _$GymThemeController {
  @override
  GymThemeState build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return _fallbackState;
    return ref.watch(_themeStateForGymProvider(gymId)).valueOrNull ?? _fallbackState;
  }

  Future<void> selectTheme(String id) async {
    final theme = state.themes.firstWhere((t) => t.id == id);
    ref.read(themeControllerProvider.notifier).setAccentColor(theme.primary);
    state = state.copyWith(activeThemeId: id);

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await ref.read(gymThemeRepositoryProvider).selectTheme(gymId, theme, watermarkEnabled: state.watermarkEnabled);
  }

  Future<void> addTheme(GymTheme theme) async {
    final presets = [...state.themes, theme];
    state = state.copyWith(themes: presets);

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId != null) {
      await ref.read(gymThemeRepositoryProvider).savePresets(gymId, presets);
    }
    await selectTheme(theme.id);
  }

  Future<void> toggleWatermark() async {
    final enabled = !state.watermarkEnabled;
    state = state.copyWith(watermarkEnabled: enabled);

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await ref.read(gymThemeRepositoryProvider).setWatermarkEnabled(gymId, enabled);
  }

  GymTheme get activeTheme => state.themes.firstWhere((t) => t.id == state.activeThemeId);
}
