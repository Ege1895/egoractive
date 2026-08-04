import 'package:freezed_annotation/freezed_annotation.dart';

import 'schedule_slot.dart';

part 'trainer_calendar_state.freezed.dart';

enum TrainerCalendarViewMode { week, month }

@freezed
class TrainerCalendarState with _$TrainerCalendarState {
  const factory TrainerCalendarState({
    required DateTime selectedDate,
    required Map<int, List<ScheduleSlot>> slotsByDayOfMonth,
    @Default(TrainerCalendarViewMode.week) TrainerCalendarViewMode viewMode,
  }) = _TrainerCalendarState;
}
