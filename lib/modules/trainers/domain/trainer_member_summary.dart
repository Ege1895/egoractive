import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_member_summary.freezed.dart';

@freezed
class TrainerMemberSummary with _$TrainerMemberSummary {
  const factory TrainerMemberSummary({
    required String id,
    required String initials,
    required String name,
    required String packageName,
    required int remainingSessions,
  }) = _TrainerMemberSummary;
}
