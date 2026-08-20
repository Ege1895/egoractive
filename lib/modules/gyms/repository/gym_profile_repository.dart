import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';
import '../service/gym_profile_service.dart';

part 'gym_profile_repository.g.dart';

abstract interface class GymProfileRepository {
  Stream<GymProfile> watchProfile(String gymId);

  Future<void> saveProfile(String gymId, GymProfile profile);
}

class GymProfileRepositoryImpl implements GymProfileRepository {
  const GymProfileRepositoryImpl(this._service);

  final GymProfileService _service;

  @override
  Stream<GymProfile> watchProfile(String gymId) => _service.watchProfile(gymId);

  @override
  Future<void> saveProfile(String gymId, GymProfile profile) =>
      _service.saveProfile(gymId, profile);
}

@riverpod
GymProfileRepository gymProfileRepository(GymProfileRepositoryRef ref) {
  return GymProfileRepositoryImpl(ref.watch(gymProfileServiceProvider));
}
