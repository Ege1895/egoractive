import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_rules.dart';
import '../service/gym_rules_service.dart';

part 'gym_rules_repository.g.dart';

abstract interface class GymRulesRepository {
  Stream<GymRules> watchRules(String gymId);
  Future<void> saveRules(String gymId, List<dynamic> delta);
}

class GymRulesRepositoryImpl implements GymRulesRepository {
  const GymRulesRepositoryImpl(this._service);

  final GymRulesService _service;

  @override
  Stream<GymRules> watchRules(String gymId) => _service.watchRules(gymId);

  @override
  Future<void> saveRules(String gymId, List<dynamic> delta) => _service.saveRules(gymId, delta);
}

@riverpod
GymRulesRepository gymRulesRepository(GymRulesRepositoryRef ref) {
  return GymRulesRepositoryImpl(ref.watch(gymRulesServiceProvider));
}
