import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/studio_rules.dart';
import '../service/studio_rules_service.dart';

part 'studio_rules_repository.g.dart';

abstract interface class StudioRulesRepository {
  StudioRules loadRules();
}

class StudioRulesRepositoryImpl implements StudioRulesRepository {
  const StudioRulesRepositoryImpl(this._service);

  final StudioRulesService _service;

  @override
  StudioRules loadRules() => _service.loadRules();
}

@riverpod
StudioRulesRepository studioRulesRepository(StudioRulesRepositoryRef ref) {
  return StudioRulesRepositoryImpl(ref.watch(studioRulesServiceProvider));
}
