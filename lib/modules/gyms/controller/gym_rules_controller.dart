import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/gym_rules.dart';
import '../repository/gym_rules_repository.dart';

part 'gym_rules_controller.g.dart';

@riverpod
Stream<GymRules> _rulesForGym(_RulesForGymRef ref, String gymId) {
  return ref.watch(gymRulesRepositoryProvider).watchRules(gymId);
}

/// F4-5 — `gyms/{gymId}.rulesContent` (Quill Delta JSON), her rol için
/// gerçek zamanlı dinlenir. Aktif salon bilinmiyorsa (test ortamı vb.) boş
/// bir doküman gösterilir.
@riverpod
class GymRulesController extends _$GymRulesController {
  @override
  GymRules build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return const GymRules(delta: GymRules.empty);
    return ref.watch(_rulesForGymProvider(gymId)).valueOrNull ??
        const GymRules(delta: GymRules.empty);
  }

  Future<void> saveRules(List<dynamic> delta) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await ref.read(gymRulesRepositoryProvider).saveRules(gymId, delta);
  }
}
