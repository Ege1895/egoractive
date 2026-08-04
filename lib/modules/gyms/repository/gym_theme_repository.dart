import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_theme.dart';
import '../service/gym_theme_service.dart';

part 'gym_theme_repository.g.dart';

abstract interface class GymThemeRepository {
  GymThemeState loadInitial();
}

class GymThemeRepositoryImpl implements GymThemeRepository {
  const GymThemeRepositoryImpl(this._service);

  final GymThemeService _service;

  @override
  GymThemeState loadInitial() => _service.loadInitial();
}

@riverpod
GymThemeRepository gymThemeRepository(GymThemeRepositoryRef ref) {
  return GymThemeRepositoryImpl(ref.watch(gymThemeServiceProvider));
}
