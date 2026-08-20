import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_slot.freezed.dart';

enum ScheduleSlotState { planned, current, completed, absent, cancelled }

@freezed
class ScheduleSlot with _$ScheduleSlot {
  const factory ScheduleSlot({
    required String id,
    required String time,
    required String name,
    required String meta,
    required ScheduleSlotState state,
    @Default('') String memberId,
  }) = _ScheduleSlot;
}
