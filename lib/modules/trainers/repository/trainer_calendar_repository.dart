import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_calendar_state.dart';
import '../service/trainer_calendar_service.dart';

part 'trainer_calendar_repository.g.dart';

abstract interface class TrainerCalendarRepository {
  TrainerCalendarState loadInitial();
}

class TrainerCalendarRepositoryImpl implements TrainerCalendarRepository {
  const TrainerCalendarRepositoryImpl(this._service);

  final TrainerCalendarService _service;

  @override
  TrainerCalendarState loadInitial() => _service.loadInitial();
}

@riverpod
TrainerCalendarRepository trainerCalendarRepository(
  TrainerCalendarRepositoryRef ref,
) {
  return TrainerCalendarRepositoryImpl(
    ref.watch(trainerCalendarServiceProvider),
  );
}
