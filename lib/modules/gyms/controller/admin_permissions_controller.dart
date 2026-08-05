import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/admin_permissions.dart';

part 'admin_permissions_controller.g.dart';

@riverpod
Stream<AdminPermissions> _permissionsForGym(_PermissionsForGymRef ref, String gymId) {
  final rc = ref.watch(remoteConfigServiceProvider);
  return FirebaseFirestore.instance.collection('gyms').doc(gymId).snapshots().map((snapshot) {
    final data = snapshot.data()?['permissions'] as Map<String, dynamic>?;
    return AdminPermissions(
      trainerReminderDelay: _delayFromMinutes(
        (data?['trainerReminderDelayMinutes'] as num?)?.toInt() ?? rc.defaultTrainerReminderDelayMinutes,
      ),
      onlineBookingEnabled: (data?['onlineBookingEnabled'] as bool?) ?? rc.defaultOnlineBookingEnabled,
      allowSessionsAfterPackageExpiry:
          (data?['allowSessionsAfterPackageExpiry'] as bool?) ?? rc.defaultAllowSessionsAfterPackageExpiry,
      memberCanCancelSession: (data?['memberCanCancelSession'] as bool?) ?? rc.defaultMemberCanCancelSession,
    );
  });
}

TrainerReminderDelay _delayFromMinutes(int minutes) => switch (minutes) {
      15 => TrainerReminderDelay.fifteenMinutes,
      60 => TrainerReminderDelay.oneHour,
      _ => TrainerReminderDelay.thirtyMinutes,
    };

int _minutesFromDelay(TrainerReminderDelay delay) => switch (delay) {
      TrainerReminderDelay.fifteenMinutes => 15,
      TrainerReminderDelay.thirtyMinutes => 30,
      TrainerReminderDelay.oneHour => 60,
    };

/// F3-6 — salon bazlı override `gyms/{gymId}.permissions` altında saklanır;
/// bir alan yazılmamışsa Remote Config'teki global varsayılana düşülür.
/// Aktif salon bilinmiyorsa (test ortamı vb.) tamamen RC varsayılanlarında
/// kalır.
@riverpod
class AdminPermissionsController extends _$AdminPermissionsController {
  @override
  AdminPermissions build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return const AdminPermissions();
    return ref.watch(_permissionsForGymProvider(gymId)).valueOrNull ?? const AdminPermissions();
  }

  Future<void> setReminderDelay(TrainerReminderDelay delay) =>
      _updateField('trainerReminderDelayMinutes', _minutesFromDelay(delay));

  Future<void> toggleOnlineBooking() => _updateField('onlineBookingEnabled', !state.onlineBookingEnabled);

  Future<void> toggleAllowSessionsAfterExpiry() =>
      _updateField('allowSessionsAfterPackageExpiry', !state.allowSessionsAfterPackageExpiry);

  Future<void> toggleMemberCanCancel() =>
      _updateField('memberCanCancelSession', !state.memberCanCancelSession);

  Future<void> _updateField(String field, Object value) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
      'permissions': {field: value},
    }, SetOptions(merge: true));
  }
}
