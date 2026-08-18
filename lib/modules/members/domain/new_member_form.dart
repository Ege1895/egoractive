import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_member_form.freezed.dart';

enum MemberGender { erkek, kadin }

extension MemberGenderLabel on MemberGender {
  String get label => switch (this) {
    MemberGender.erkek => 'Erkek',
    MemberGender.kadin => 'Kadın',
  };
}

@freezed
class NewMemberForm with _$NewMemberForm {
  const factory NewMemberForm({
    required String firstName,
    required String lastName,
    required String phoneDigits,
    required int birthYear,
    required int heightCm,
    MemberGender? gender,
    String? trainerId,
    String? trainerName,
    required String note,
  }) = _NewMemberForm;

  const NewMemberForm._();

  int get age => DateTime.now().year - birthYear;
}
