import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/gym_theme.dart';
import '../repository/gym_theme_repository.dart';

part 'gym_theme_controller.g.dart';

const _fallbackState = GymThemeState(
  activeThemeId: 'egora-mavisi',
  themes: [
    GymTheme(
      id: 'egora-mavisi',
      name: 'Egora Mavisi',
      primary: Color(0xFF05A6FA),
      soft: Color(0xFF48C2FF),
      note: 'Varsayılan tema',
    ),
    GymTheme(
      id: 'turuncu-enerji',
      name: 'Turuncu Enerji',
      primary: Color(0xFFFF8A3D),
      soft: Color(0xFFFFB27A),
      note: 'Sıcak, enerjik vurgu',
    ),
    GymTheme(
      id: 'yesil-doga',
      name: 'Yeşil Doğa',
      primary: Color(0xFF2ED393),
      soft: Color(0xFF7FE8C4),
      note: 'Sakin, doğal vurgu',
    ),
  ],
);

@riverpod
Stream<GymThemeState> _themeStateForGym(
  _ThemeStateForGymRef ref,
  String gymId,
) {
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
    return ref.watch(_themeStateForGymProvider(gymId)).valueOrNull ??
        _fallbackState;
  }

  /// Yazma başarısız olursa (network/izin) hem local state hem de anlık
  /// önizleme için optimistik güncellenen global [ThemeController] önceki
  /// değerine geri alınır — aksi halde tema değişmiş gibi görünür ama
  /// diğer cihazlara hiç yansımamış olabilir.
  Future<void> selectTheme(String id) async {
    final previousThemeId = state.activeThemeId;
    final previousTheme = activeTheme;
    final theme = state.themes.firstWhere((t) => t.id == id);
    ref.read(themeControllerProvider.notifier).setAccentColor(theme.primary);
    state = state.copyWith(activeThemeId: id, errorMessage: null);

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    try {
      await ref
          .read(gymThemeRepositoryProvider)
          .selectTheme(gymId, theme, watermarkEnabled: state.watermarkEnabled);
    } catch (_) {
      state = state.copyWith(
        activeThemeId: previousThemeId,
        errorMessage: 'Tema kaydedilemedi, tekrar dene.',
      );
      ref
          .read(themeControllerProvider.notifier)
          .setAccentColor(previousTheme.primary);
    }
  }

  Future<void> addTheme(GymTheme theme) async {
    final presets = [...state.themes, theme];
    state = state.copyWith(themes: presets, errorMessage: null);

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId != null) {
      try {
        await ref.read(gymThemeRepositoryProvider).savePresets(gymId, presets);
      } catch (_) {
        state = state.copyWith(
          themes: state.themes.where((t) => t.id != theme.id).toList(),
          errorMessage: 'Tema eklenemedi, tekrar dene.',
        );
        return;
      }
    }
    await selectTheme(theme.id);
  }

  /// Admin'in kendi eklediği bir temayı kayıtlı temalar arasından kaldırır.
  /// Hazır temalar (bkz. [isGymThemeDeletable]) çağrılsa bile korunur.
  ///
  /// [showAppConfirmDialog] hatayı diyaloğun İÇİNDE gösterip kullanıcıya
  /// tekrar deneme şansı verdiği için, yazma başarısız olursa state geri
  /// alınıp hata YENİDEN FIRLATILIYOR — burada `errorMessage`'a yazmak,
  /// diyalog kapandıktan sonra panelin tepesinde alakasız bir hata
  /// bırakırdı (bkz. [addTheme]'deki farklı, diyalogsuz akış).
  Future<void> deleteTheme(String id) async {
    if (!isGymThemeDeletable(id)) return;
    final previousThemes = state.themes;
    final remaining = previousThemes.where((t) => t.id != id).toList();
    if (remaining.isEmpty) return;

    state = state.copyWith(themes: remaining, errorMessage: null);
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId != null) {
      try {
        await ref.read(gymThemeRepositoryProvider).savePresets(gymId, remaining);
      } catch (_) {
        state = state.copyWith(themes: previousThemes);
        rethrow;
      }
    }

    // Silinen tema o an SEÇİLİ olabilir; bu durumda hem `themeColors`
    // hem de global [ThemeController] hâlâ silinmiş temanın rengini
    // taşır. Varsayılan temaya dönerek ikisini de tutarlı hale getiriyoruz.
    if (state.activeThemeId == id) {
      await selectTheme(remaining.first.id);
    }
  }

  Future<void> toggleWatermark() async {
    final previous = state.watermarkEnabled;
    final enabled = !previous;
    state = state.copyWith(watermarkEnabled: enabled, errorMessage: null);

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    try {
      await ref
          .read(gymThemeRepositoryProvider)
          .setWatermarkEnabled(gymId, enabled);
    } catch (_) {
      state = state.copyWith(
        watermarkEnabled: previous,
        errorMessage: 'Ayar kaydedilemedi, tekrar dene.',
      );
    }
  }

  GymTheme get activeTheme =>
      state.themes.firstWhere((t) => t.id == state.activeThemeId);
}
