import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_calendar_state.dart';
import '../repository/trainer_calendar_repository.dart';

part 'trainer_calendar_controller.g.dart';

@riverpod
class TrainerCalendarController extends _$TrainerCalendarController {
  @override
  TrainerCalendarState build() => ref.watch(trainerCalendarRepositoryProvider).loadInitial();

  void setViewMode(TrainerCalendarViewMode mode) => state = state.copyWith(viewMode: mode);

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);
}
