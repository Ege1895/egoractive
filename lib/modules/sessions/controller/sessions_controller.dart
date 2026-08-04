import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/session.dart';
import '../domain/sessions_state.dart';
import '../repository/sessions_repository.dart';

part 'sessions_controller.g.dart';

@riverpod
class SessionsController extends _$SessionsController {
  @override
  SessionsState build() => ref.watch(sessionsRepositoryProvider).loadInitial();

  void setViewMode(SessionsViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void confirmAttendance(bool coming) {
    state = state.copyWith(attendanceAnswer: coming ? AttendanceAnswer.coming : AttendanceAnswer.notComing);
  }

  void resetAttendance() {
    state = state.copyWith(attendanceAnswer: AttendanceAnswer.pending);
  }
}
