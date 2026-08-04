import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/gym_theme.dart';
import '../repository/gym_theme_repository.dart';

part 'gym_theme_controller.g.dart';

@riverpod
class GymThemeController extends _$GymThemeController {
  @override
  GymThemeState build() {
    final initial = ref.watch(gymThemeRepositoryProvider).loadInitial();
    final active = initial.themes.firstWhere((t) => t.id == initial.activeThemeId);
    Future.microtask(() => ref.read(themeControllerProvider.notifier).setAccentColor(active.primary));
    return initial;
  }

  void selectTheme(String id) {
    final theme = state.themes.firstWhere((t) => t.id == id);
    ref.read(themeControllerProvider.notifier).setAccentColor(theme.primary);
    state = state.copyWith(activeThemeId: id);
  }

  void addTheme(GymTheme theme) {
    state = state.copyWith(themes: [...state.themes, theme]);
    selectTheme(theme.id);
  }

  void toggleWatermark() => state = state.copyWith(watermarkEnabled: !state.watermarkEnabled);

  GymTheme get activeTheme => state.themes.firstWhere((t) => t.id == state.activeThemeId);
}
