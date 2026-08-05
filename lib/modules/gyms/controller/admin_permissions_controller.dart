import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_permissions.dart';

part 'admin_permissions_controller.g.dart';

/// Mock kontrolcü — F2'de gerçek `gyms/{gymId}.permissions` alanına
/// bağlanacak.
@riverpod
class AdminPermissionsController extends _$AdminPermissionsController {
  @override
  AdminPermissions build() => const AdminPermissions();

  void setReminderDelay(TrainerReminderDelay delay) => state = state.copyWith(trainerReminderDelay: delay);

  void toggleOnlineBooking() => state = state.copyWith(onlineBookingEnabled: !state.onlineBookingEnabled);

  void toggleAllowSessionsAfterExpiry() => state = state.copyWith(allowSessionsAfterPackageExpiry: !state.allowSessionsAfterPackageExpiry);

  void toggleMemberCanCancel() => state = state.copyWith(memberCanCancelSession: !state.memberCanCancelSession);
}
