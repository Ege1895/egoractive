import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_permissions.freezed.dart';

enum TrainerReminderDelay { fifteenMinutes, thirtyMinutes, oneHour }

extension TrainerReminderDelayLabel on TrainerReminderDelay {
  String get label => switch (this) {
    TrainerReminderDelay.fifteenMinutes => '15 dakika',
    TrainerReminderDelay.thirtyMinutes => '30 dakika',
    TrainerReminderDelay.oneHour => '1 saat',
  };
}

@freezed
class AdminPermissions with _$AdminPermissions {
  const factory AdminPermissions({
    @Default(TrainerReminderDelay.thirtyMinutes)
    TrainerReminderDelay trainerReminderDelay,

    /// Antrenör, üyelerinin seanslarını iptal edebilir mi —
    /// `firestore.rules`'taki `trainerPermission('canCancelMemberSessions')`
    /// ile canlı olarak zorlanır (bu sadece UI değil, gerçek bir kural).
    @Default(true) bool canCancelMemberSessions,

    /// Antrenör, üyelerinin seanslarını erteleyebilir mi — aynı şekilde
    /// `trainerPermission('canRescheduleMemberSessions')` ile zorlanır.
    @Default(true) bool canRescheduleMemberSessions,
  }) = _AdminPermissions;
}
