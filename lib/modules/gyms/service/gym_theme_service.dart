import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_theme.dart';

part 'gym_theme_service.g.dart';

const _defaultPresets = [
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
];

/// F4-6 — `gyms/{gymId}.themeColors` (aktif renk + logo silüeti tercihi) ve
/// `gyms/{gymId}.themePresets` (admin'in eklediği tema kataloğu). `ThemeController`
/// (F1-6) `themeColors.primary`'yi zaten stream olarak dinliyor — buradaki
/// yazmalar sayesinde değişiklik yeniden başlatmadan tüm aktif client'lara
/// yansır (kabul kriteri).
class GymThemeService {
  const GymThemeService();

  Stream<GymThemeState> watchState(String gymId) {
    return FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          final presetsData = data?['themePresets'] as List? ?? const [];
          final presets = presetsData
              .map(_themeFromMap)
              .whereType<GymTheme>()
              .toList();
          final themes = presets.isEmpty ? _defaultPresets : presets;

          final colorsData = data?['themeColors'] as Map<String, dynamic>?;
          final activeThemeId =
              (colorsData?['activeThemeId'] as String?) ?? themes.first.id;
          final watermarkEnabled =
              (colorsData?['watermarkEnabled'] as bool?) ?? true;

          return GymThemeState(
            themes: themes,
            activeThemeId: themes.any((t) => t.id == activeThemeId)
                ? activeThemeId
                : themes.first.id,
            watermarkEnabled: watermarkEnabled,
          );
        });
  }

  Future<void> selectTheme(
    String gymId,
    GymTheme theme, {
    required bool watermarkEnabled,
  }) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
      'themeColors': {
        'primary': _toHex(theme.primary),
        'soft': _toHex(theme.soft),
        'activeThemeId': theme.id,
        'watermarkEnabled': watermarkEnabled,
      },
    }, SetOptions(merge: true));
  }

  Future<void> savePresets(String gymId, List<GymTheme> presets) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
      'themePresets': presets.map(_themeToMap).toList(),
    }, SetOptions(merge: true));
  }

  Future<void> setWatermarkEnabled(String gymId, bool enabled) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
      'themeColors': {'watermarkEnabled': enabled},
    }, SetOptions(merge: true));
  }

  Map<String, dynamic> _themeToMap(GymTheme theme) => {
    'id': theme.id,
    'name': theme.name,
    'primary': _toHex(theme.primary),
    'soft': _toHex(theme.soft),
    'note': theme.note,
  };

  GymTheme? _themeFromMap(dynamic raw) {
    if (raw is! Map) return null;
    final primary = _fromHex(raw['primary'] as String?);
    final soft = _fromHex(raw['soft'] as String?);
    final id = raw['id'] as String?;
    final name = raw['name'] as String?;
    if (primary == null || soft == null || id == null || name == null)
      return null;
    return GymTheme(
      id: id,
      name: name,
      primary: primary,
      soft: soft,
      note: (raw['note'] as String?) ?? '',
    );
  }

  String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  Color? _fromHex(String? hex) {
    if (hex == null) return null;
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6) return null;
    final value = int.tryParse('FF$cleaned', radix: 16);
    return value == null ? null : Color(value);
  }
}

@riverpod
GymThemeService gymThemeService(GymThemeServiceRef ref) =>
    const GymThemeService();
