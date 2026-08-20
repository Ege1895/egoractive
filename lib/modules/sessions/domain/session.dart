import 'package:freezed_annotation/freezed_annotation.dart';

part 'session.freezed.dart';

enum SessionStatus { planned, completed, absent, cancelled }

enum AttendanceAnswer { pending, coming, notComing }

@freezed
class Session with _$Session {
  const factory Session({
    required String id,
    required String day,
    required String month,
    required String title,
    required String meta,
    required SessionStatus status,
    @Default(AttendanceAnswer.pending) AttendanceAnswer confirmation,
  }) = _Session;
}
