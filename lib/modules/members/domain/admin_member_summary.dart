import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_member_summary.freezed.dart';

enum MemberPackageStatus { active, endingSoon, none }

@freezed
class AdminMemberSummary with _$AdminMemberSummary {
  const factory AdminMemberSummary({
    required String id,
    required String initials,
    required String name,
    required String phone,
    required String trainerName,
    required int remainingSessions,
    required String packageEndDate,
    required MemberPackageStatus status,
  }) = _AdminMemberSummary;
}
