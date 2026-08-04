import 'package:freezed_annotation/freezed_annotation.dart';

import 'pending_confirmation.dart';
import 'schedule_slot.dart';

part 'trainer_home_state.freezed.dart';

@freezed
class TrainerHomeState with _$TrainerHomeState {
  const factory TrainerHomeState({
    required int todaySessionCount,
    required int completedCount,
    required int freeSlotCount,
    required List<PendingConfirmation> pendingConfirmations,
    required List<ScheduleSlot> todaySchedule,
  }) = _TrainerHomeState;
}
