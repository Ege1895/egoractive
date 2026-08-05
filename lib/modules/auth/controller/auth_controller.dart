import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../domain/auth_login_exception.dart';
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
    state = state.copyWith(isRequestingLogin: true, loginErrorMessage: null);
    try {
      await ref.read(authRepositoryProvider).login(state.phoneDigits);
      state = state.copyWith(isRequestingLogin: false);
    } on AuthLoginException catch (e) {
      state = state.copyWith(isRequestingLogin: false, loginErrorMessage: _messageFor(e.reason));
    }
  }

  void toggleDeleteAcknowledged() {
    state = state.copyWith(deleteAccountAcknowledged: !state.deleteAccountAcknowledged);
  }

  /// Başarılıysa `true` döner (çağıran taraf login ekranına yönlendirir).
  Future<bool> deleteAccount() async {
    if (!state.deleteAccountAcknowledged || state.isDeletingAccount) return false;
    state = state.copyWith(isDeletingAccount: true, deleteAccountErrorMessage: null);
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
      state = state.copyWith(isDeletingAccount: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isDeletingAccount: false,
        deleteAccountErrorMessage: ref.read(remoteConfigServiceProvider).getText(
              RemoteConfigKeys.authDeleteAccountErrorGeneric,
            ),
      );
      return false;
    }
  }

  void selectAvatar(int index) {
    state = state.copyWith(selectedAvatarIndex: index);
  }

  void toggleSessionReminder() {
    state = state.copyWith(sessionReminderEnabled: !state.sessionReminderEnabled);
  }

  /// Oturumu kapatır — F1-11'de gerçek `FirebaseAuth.signOut()` çağıracak.
  void logout() {
    state = const AuthState();
  }

  String _messageFor(AuthLoginErrorReason reason) {
    final rc = ref.read(remoteConfigServiceProvider);
    final key = switch (reason) {
      AuthLoginErrorReason.notFound => RemoteConfigKeys.authLoginErrorNotFound,
      AuthLoginErrorReason.rateLimited => RemoteConfigKeys.authLoginErrorRateLimited,
      AuthLoginErrorReason.generic => RemoteConfigKeys.authLoginErrorGeneric,
    };
    return rc.getText(key);
  }
}
