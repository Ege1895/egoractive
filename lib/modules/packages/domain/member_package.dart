import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_package.freezed.dart';

@freezed
class MemberPackage with _$MemberPackage {
  const factory MemberPackage({
    required String name,
    required int remainingSessions,
    required int totalSessions,
    required int makeupSessions,
    required String startDate,
    required String endDate,
    required String trainerName,
    required String trainerSpecialty,
    required String trainerInitials,
  }) = _MemberPackage;

  const MemberPackage._();

  static const empty = MemberPackage(
    name: 'Aktif paket yok',
    remainingSessions: 0,
    totalSessions: 0,
    makeupSessions: 0,
    startDate: '—',
    endDate: '—',
    trainerName: '—',
    trainerSpecialty: '',
    trainerInitials: '?',
  );

  double get progressRatio =>
      totalSessions == 0 ? 0 : remainingSessions / totalSessions;
}
