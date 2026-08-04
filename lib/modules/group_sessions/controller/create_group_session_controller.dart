import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/create_group_session_form.dart';
import '../repository/create_group_session_repository.dart';

part 'create_group_session_controller.g.dart';

@riverpod
class CreateGroupSessionController extends _$CreateGroupSessionController {
  @override
  CreateGroupSessionForm build() => ref.watch(createGroupSessionRepositoryProvider).loadInitial();

  void setTitle(String title) => state = state.copyWith(title: title);

  void toggleDay(int day) {
    final days = {...state.selectedDays};
    days.contains(day) ? days.remove(day) : days.add(day);
    state = state.copyWith(selectedDays: days);
  }

  void incrementCapacity() {
    if (state.capacity >= state.capacityMax) return;
    state = state.copyWith(capacity: state.capacity + 1);
  }

  void decrementCapacity() {
    if (state.capacity <= 1) return;
    state = state.copyWith(capacity: state.capacity - 1);
  }

  void toggleOnlineBooking() => state = state.copyWith(onlineBookingEnabled: !state.onlineBookingEnabled);
}
