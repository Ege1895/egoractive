import 'package:freezed_annotation/freezed_annotation.dart';

import 'session.dart';

part 'sessions_state.freezed.dart';

enum SessionsViewMode { list, calendar }

@freezed
class WeekActivityDay with _$WeekActivityDay {
  const factory WeekActivityDay({
    required String label,
    required double intensity, // 0.0 - 1.0
    required bool isRestDay,
  }) = _WeekActivityDay;
}

@freezed
class PaymentWarning with _$PaymentWarning {
  const factory PaymentWarning({
    required String amount,
    required String dueDate,
  }) = _PaymentWarning;
}

@freezed
class SessionsState with _$SessionsState {
  const factory SessionsState({
    required Session nextSession,
    required List<Session> upcoming,
    required List<Session> past,
    required List<WeekActivityDay> week,
    required PaymentWarning? paymentWarning,
    @Default(SessionsViewMode.list) SessionsViewMode viewMode,
    @Default(AttendanceAnswer.pending) AttendanceAnswer attendanceAnswer,
    String? attendanceErrorMessage,
  }) = _SessionsState;
}
