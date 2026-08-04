import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_theme.dart';

part 'gym_theme_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}.themeColors` + `themes`
/// alt koleksiyonuna bağlanacak.
class GymThemeService {
  const GymThemeService();

  GymThemeState loadInitial() {
    return const GymThemeState(
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
  }
}

@riverpod
GymThemeService gymThemeService(GymThemeServiceRef ref) => const GymThemeService();
