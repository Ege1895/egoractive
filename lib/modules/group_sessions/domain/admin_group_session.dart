import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_group_session.freezed.dart';

@freezed
class AdminGroupSession with _$AdminGroupSession {
  const factory AdminGroupSession({
    required String id,
    required String name,
    required String meta,
    required int taken,
    required int capacity,
  }) = _AdminGroupSession;

  const AdminGroupSession._();

  bool get isFull => taken >= capacity;

  int get remaining => capacity - taken;
}
