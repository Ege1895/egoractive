import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_trainer_summary.dart';
import '../service/admin_trainers_service.dart';

part 'admin_trainers_repository.g.dart';

abstract interface class AdminTrainersRepository {
  List<AdminTrainerSummary> loadTrainers();
}

class AdminTrainersRepositoryImpl implements AdminTrainersRepository {
  const AdminTrainersRepositoryImpl(this._service);

  final AdminTrainersService _service;

  @override
  List<AdminTrainerSummary> loadTrainers() => _service.loadTrainers();
}

@riverpod
AdminTrainersRepository adminTrainersRepository(AdminTrainersRepositoryRef ref) {
  return AdminTrainersRepositoryImpl(ref.watch(adminTrainersServiceProvider));
}
