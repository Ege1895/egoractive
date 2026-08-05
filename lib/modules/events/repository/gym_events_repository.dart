import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_event.dart';
import '../service/gym_events_service.dart';

part 'gym_events_repository.g.dart';

abstract interface class GymEventsRepository {
  List<GymEvent> loadEvents();
}

class GymEventsRepositoryImpl implements GymEventsRepository {
  const GymEventsRepositoryImpl(this._service);

  final GymEventsService _service;

  @override
  List<GymEvent> loadEvents() => _service.loadEvents();
}

@riverpod
GymEventsRepository gymEventsRepository(GymEventsRepositoryRef ref) {
  return GymEventsRepositoryImpl(ref.watch(gymEventsServiceProvider));
}
