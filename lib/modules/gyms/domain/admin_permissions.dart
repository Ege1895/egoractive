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
    @Default(TrainerReminderDelay.thirtyMinutes) TrainerReminderDelay trainerReminderDelay,
    @Default(true) bool onlineBookingEnabled,
    @Default(false) bool allowSessionsAfterPackageExpiry,
    @Default(true) bool memberCanCancelSession,
  }) = _AdminPermissions;
}
