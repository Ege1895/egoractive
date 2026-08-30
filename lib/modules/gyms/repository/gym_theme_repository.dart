import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_theme.dart';
import '../service/gym_theme_service.dart';

part 'gym_theme_repository.g.dart';

abstract interface class GymThemeRepository {
  Stream<GymThemeState> watchState(String gymId);
  Future<void> selectTheme(
    String gymId,
    GymTheme theme, {
    required bool watermarkEnabled,
  });
  Future<void> savePresets(String gymId, List<GymTheme> presets);
  Future<void> setWatermarkEnabled(String gymId, bool enabled);
}

class GymThemeRepositoryImpl implements GymThemeRepository {
  const GymThemeRepositoryImpl(this._service);

  final GymThemeService _service;

  @override
  Stream<GymThemeState> watchState(String gymId) => _service.watchState(gymId);

  @override
  Future<void> selectTheme(
    String gymId,
    GymTheme theme, {
    required bool watermarkEnabled,
  }) => _service.selectTheme(gymId, theme, watermarkEnabled: watermarkEnabled);

  @override
  Future<void> savePresets(String gymId, List<GymTheme> presets) =>
      _service.savePresets(gymId, presets);

  @override
  Future<void> setWatermarkEnabled(String gymId, bool enabled) =>
      _service.setWatermarkEnabled(gymId, enabled);
}

@riverpod
GymThemeRepository gymThemeRepository(GymThemeRepositoryRef ref) {
  return GymThemeRepositoryImpl(ref.watch(gymThemeServiceProvider));
}
