import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';
import '../service/gym_profile_service.dart';

part 'gym_profile_repository.g.dart';

abstract interface class GymProfileRepository {
  GymProfile loadProfile();
}

class GymProfileRepositoryImpl implements GymProfileRepository {
  const GymProfileRepositoryImpl(this._service);

  final GymProfileService _service;

  @override
  GymProfile loadProfile() => _service.loadProfile();
}

@riverpod
GymProfileRepository gymProfileRepository(GymProfileRepositoryRef ref) {
  return GymProfileRepositoryImpl(ref.watch(gymProfileServiceProvider));
}
