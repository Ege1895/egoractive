import 'package:freezed_annotation/freezed_annotation.dart';

part 'gym_profile.freezed.dart';

@freezed
class GymProfile with _$GymProfile {
  const factory GymProfile({
    required String name,
    required String city,

    /// F8-4 — global telefon numarası desteği. E.164 (`+905324187605`).
    required String phone,
    @Default(false) bool isPhoneValid,
    required String address,
    @Default('') String logoUrl,
  }) = _GymProfile;
}
