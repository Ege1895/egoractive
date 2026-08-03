import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/auth_state.dart';
import '../repository/auth_repository.dart';

part 'auth_controller.g.dart';

@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() => const AuthState();

  void appendDigit(String digit) {
    if (state.phoneDigits.length >= 10) return;
    state = state.copyWith(phoneDigits: state.phoneDigits + digit);
  }

  void removeLastDigit() {
    if (state.phoneDigits.isEmpty) return;
    state = state.copyWith(
      phoneDigits: state.phoneDigits.substring(0, state.phoneDigits.length - 1),
    );
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
}
