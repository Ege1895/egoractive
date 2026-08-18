import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/new_member_form.dart';

part 'new_member_controller.g.dart';

/// Yeni üye kayıt akışının (P4-5 → P4-6 → P4-7) formu — geri tuşuyla önceki
/// adıma dönüldüğünde veri kaybolmasın diye tek bir kalıcı state'te tutulur.
@riverpod
class NewMemberController extends _$NewMemberController {
  @override
  NewMemberForm build() {
    return NewMemberForm(
      firstName: '',
      lastName: '',
      phoneDigits: '',
      birthYear: 1995,
      heightCm: 170,
      note: '',
      registeredAt: DateTime.now(),
    );
  }

  void updateFirstName(String value) =>
      state = state.copyWith(firstName: value);

  void updateLastName(String value) => state = state.copyWith(lastName: value);

  void updatePhoneDigits(String value) =>
      state = state.copyWith(phoneDigits: value);

  void updateBirthYear(int value) => state = state.copyWith(birthYear: value);

  void updateHeightCm(int value) => state = state.copyWith(heightCm: value);

  /// Zaten seçili olan cinsiyete tekrar dokunulursa seçim kaldırılır —
  /// cinsiyet opsiyonel bir alan, admin hiç seçmeden de devam edebilir.
  void toggleGender(MemberGender value) {
    state = state.copyWith(gender: state.gender == value ? null : value);
  }

  void selectTrainer(String id, String name) =>
      state = state.copyWith(trainerId: id, trainerName: name);

  void updateNote(String value) => state = state.copyWith(note: value);

  void updateRegisteredAt(DateTime value) =>
      state = state.copyWith(registeredAt: value);

  void reset() => state = build();
}
