import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_home_state.dart';
import '../repository/trainer_home_repository.dart';

part 'trainer_home_controller.g.dart';

@riverpod
class TrainerHomeController extends _$TrainerHomeController {
  @override
  TrainerHomeState build() => ref.watch(trainerHomeRepositoryProvider).loadInitial();

  void markCompleted(String pendingId) {
    state = state.copyWith(
      pendingConfirmations: state.pendingConfirmations.where((p) => p.id != pendingId).toList(),
      completedCount: state.completedCount + 1,
    );
  }

  void markAbsent(String pendingId) {
    state = state.copyWith(
      pendingConfirmations: state.pendingConfirmations.where((p) => p.id != pendingId).toList(),
    );
  }
}
