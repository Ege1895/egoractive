import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth_state.dart';
import '../repository/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  /// Native numeric klavyeden gelen ham metni 10 haneye kırpıp state'e yazar.
  void setPhoneDigits(String rawInput) {
    final digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
    state = state.copyWith(phoneDigits: digits.length > 10 ? digits.substring(0, 10) : digits);
  }

  Future<void> requestLogin() async {
    if (!state.isPhoneComplete || state.isRequestingLogin) return;
    state = state.copyWith(isRequestingLogin: true);
    await ref.read(authRepositoryProvider).login(state.phoneDigits);
    state = state.copyWith(isRequestingLogin: false);
  }

  void toggleDeleteAcknowledged() {
    state = state.copyWith(deleteAccountAcknowledged: !state.deleteAccountAcknowledged);
  }

  Future<void> deleteAccount() async {
    if (!state.deleteAccountAcknowledged || state.isDeletingAccount) return;
    state = state.copyWith(isDeletingAccount: true);
    await ref.read(authRepositoryProvider).deleteAccount();
    state = state.copyWith(isDeletingAccount: false);
  }

  void selectAvatar(int index) {
    state = state.copyWith(selectedAvatarIndex: index);
  }

  void toggleSessionReminder() {
    state = state.copyWith(sessionReminderEnabled: !state.sessionReminderEnabled);
  }

  /// Oturumu kapatır — F1-10'da gerçek `FirebaseAuth.signOut()` çağıracak.
  void logout() {
    state = const AuthState();
  }
}
