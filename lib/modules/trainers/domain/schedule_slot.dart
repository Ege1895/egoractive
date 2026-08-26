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
    /// Seansın gerçek başlangıç zamanı — antrenörün "Dersi onayla"
    /// sheet'inin 24 saatlik onay penceresini hesaplamak için gerekli
    /// (bkz. `trainer_calendar_panel.dart`, `_showSlotDetail`).
    required DateTime startTime,
    @Default('') String memberId,
  }) = _ScheduleSlot;
}
