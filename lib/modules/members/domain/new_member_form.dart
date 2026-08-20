import 'package:freezed_annotation/freezed_annotation.dart';

part 'new_member_form.freezed.dart';

enum MemberGender { erkek, kadin }

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
    required DateTime registeredAt,

    /// Üyenin ana ekranında sıradaki dersi için "Gelicem"/"Gelmeyeceğim"
    /// bildirimi yapabilme yetkisi — admin açıkça açmadıkça kapalı gelir.
    @Default(false) bool canConfirmAttendance,
  }) = _NewMemberForm;

  const NewMemberForm._();

  int get age => DateTime.now().year - birthYear;
}
