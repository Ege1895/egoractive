import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_event.dart';
import '../repository/gym_events_repository.dart';

part 'gym_events_controller.g.dart';

@riverpod
class GymEventsController extends _$GymEventsController {
  @override
  List<GymEvent> build() => ref.watch(gymEventsRepositoryProvider).loadEvents();

  void addEvent(GymEvent event) => state = [...state, event];
}
