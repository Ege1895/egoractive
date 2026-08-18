import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';
import '../repository/gym_profile_repository.dart';

part 'gym_profile_controller.g.dart';

@riverpod
class GymProfileController extends _$GymProfileController {
  @override
  GymProfile build() => ref.watch(gymProfileRepositoryProvider).loadProfile();

  /// [GymSetupPanel] (yeni salon oluşturma) her açıldığında çağırır — bu
  /// provider [GymInfoPanel] (mevcut salonu düzenleme) ile paylaşıldığı ve
  /// panel stack eski panelleri `maintainState` ile canlı tuttuğu için,
  /// `build()`'ın autoDispose ile kendiliğinden sıfırlanacağı garanti değil.
  void reset() => state = ref.read(gymProfileRepositoryProvider).loadProfile();

  void updateName(String name) => state = state.copyWith(name: name);

  void updateCity(String city) => state = state.copyWith(city: city);

  /// Salonu oluşturan kişi bu numarayla giriş yapacağı için (F2-9), sadece
  /// rakamlar (en fazla 10 hane) tutulur — [AuthController.setPhoneDigits]
  /// ile aynı temsil, `+90` öneki gönderim anında eklenir.
  void updatePhone(String rawInput) {
    final digits = rawInput.replaceAll(RegExp(r'[^0-9]'), '');
    state = state.copyWith(
      phone: digits.length > 10 ? digits.substring(0, 10) : digits,
    );
  }

  void updateAddress(String address) =>
      state = state.copyWith(address: address);
}
