import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_theme.freezed.dart';

/// Uygulamayla birlikte gelen hazır temaların id'leri. Admin bunları
/// silemez; sadece kendi eklediklerini (logo renginden türetilenler dahil)
/// kaldırabilir. `gym_theme_service.dart`'taki `_defaultPresets` listesiyle
/// AYNI id'leri taşımalı — orası bu temaların içeriğini, burası kimliğini
/// tanımlıyor.
const defaultGymThemeIds = {'egora-mavisi', 'turuncu-enerji', 'yesil-doga'};

/// Varsayılan tema — listede her zaman en üstte durur ve silinemez.
const defaultGymThemeId = 'egora-mavisi';

/// Bir temanın silinebilir olup olmadığı. Hazır temalar korumalı: liste
/// şişmesinin kaynağı admin'in kendi eklediği temalar, hazır olanları
/// silmek ise geri dönüşü olmayan bir kayıp olurdu.
bool isGymThemeDeletable(String themeId) =>
    !defaultGymThemeIds.contains(themeId);

/// [themes] listesini, varsayılan tema HER ZAMAN en başta olacak şekilde
/// döner; kalanların göreli sırası korunur. Sıra Firestore'daki
/// `themePresets` dizisinden geldiği için, eski/elle düzenlenmiş bir
/// kayıtta varsayılan tema başta olmayabilir.
List<GymTheme> sortedGymThemes(List<GymTheme> themes) {
  final index = themes.indexWhere((t) => t.id == defaultGymThemeId);
  if (index <= 0) return themes;
  return [themes[index], ...themes.where((t) => t.id != defaultGymThemeId)];
}

@freezed
class GymTheme with _$GymTheme {
  const factory GymTheme({
    required String id,
    required String name,
    required Color primary,
    required Color soft,
    required String note,
  }) = _GymTheme;
}

@freezed
class GymThemeState with _$GymThemeState {
  const factory GymThemeState({
    required List<GymTheme> themes,
    required String activeThemeId,
    @Default(true) bool watermarkEnabled,
    String? errorMessage,
  }) = _GymThemeState;
}
