import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_home_state.dart';
import '../service/trainer_home_service.dart';

part 'trainer_home_repository.g.dart';

abstract interface class TrainerHomeRepository {
  TrainerHomeState loadInitial();
}

class TrainerHomeRepositoryImpl implements TrainerHomeRepository {
  const TrainerHomeRepositoryImpl(this._service);

  final TrainerHomeService _service;

  @override
  TrainerHomeState loadInitial() => _service.loadInitial();
}

@riverpod
TrainerHomeRepository trainerHomeRepository(TrainerHomeRepositoryRef ref) {
  return TrainerHomeRepositoryImpl(ref.watch(trainerHomeServiceProvider));
}
