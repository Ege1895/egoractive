import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_calendar_state.freezed.dart';

enum AdminSessionState { planned, current, completed, cancelled }

@freezed
class AdminSessionSlot with _$AdminSessionSlot {
  const factory AdminSessionSlot({
    required String id,
    required String time,
    required String title,
    required String meta,
    required AdminSessionState state,
  }) = _AdminSessionSlot;
}

@freezed
class AdminCalendarState with _$AdminCalendarState {
  const factory AdminCalendarState({
    required DateTime selectedDate,
    required Map<int, List<AdminSessionSlot>> slotsByDayOfMonth,
  }) = _AdminCalendarState;
}
