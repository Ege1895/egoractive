import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_profile.dart';
import '../repository/gym_profile_repository.dart';

part 'gym_profile_controller.g.dart';

@riverpod
class GymProfileController extends _$GymProfileController {
  @override
  GymProfile build() => ref.watch(gymProfileRepositoryProvider).loadProfile();

  void updateName(String name) => state = state.copyWith(name: name);

  void updateCity(String city) => state = state.copyWith(city: city);

  void updatePhone(String phone) => state = state.copyWith(phone: phone);

  void updateAddress(String address) => state = state.copyWith(address: address);
}
