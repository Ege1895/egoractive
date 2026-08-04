import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_profile.freezed.dart';

@freezed
class GymProfile with _$GymProfile {
  const factory GymProfile({
    required String name,
    required String city,
    required String phone,
    required String address,
  }) = _GymProfile;
}
