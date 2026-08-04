import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_trainer_summary.dart';
import '../repository/admin_trainers_repository.dart';

part 'admin_trainers_controller.g.dart';

@riverpod
class AdminTrainersController extends _$AdminTrainersController {
  @override
  List<AdminTrainerSummary> build() => ref.watch(adminTrainersRepositoryProvider).loadTrainers();

  void addTrainer(AdminTrainerSummary trainer) => state = [...state, trainer];
}
