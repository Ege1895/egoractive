import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_rules.dart';
import '../service/gym_rules_service.dart';
import '../../../shared/utils/date_labels.dart';

part 'gym_rules_repository.g.dart';

abstract interface class GymRulesRepository {
  Stream<GymRules> watchRules(String gymId, DateLabels labels);
  Future<void> saveRules(String gymId, List<dynamic> delta);
}

class GymRulesRepositoryImpl implements GymRulesRepository {
  const GymRulesRepositoryImpl(this._service);

  final GymRulesService _service;

  @override
  Stream<GymRules> watchRules(String gymId, DateLabels labels) =>
      _service.watchRules(gymId, labels);

  @override
  Future<void> saveRules(String gymId, List<dynamic> delta) =>
      _service.saveRules(gymId, delta);
}

@riverpod
GymRulesRepository gymRulesRepository(GymRulesRepositoryRef ref) {
  return GymRulesRepositoryImpl(ref.watch(gymRulesServiceProvider));
}
