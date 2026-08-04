import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/mock/member_mock_profile.dart';
import '../domain/member_package.dart';

part 'package_service.g.dart';

/// Mock servis — Faz 2'de `memberPackages/{id}` dokümanına bağlanacak.
class PackageService {
  const PackageService();

  MemberPackage loadActivePackage() {
    return const MemberPackage(
      name: MemberMockProfile.packageName,
      remainingSessions: MemberMockProfile.remainingSessions,
      totalSessions: MemberMockProfile.totalSessions,
      makeupSessions: MemberMockProfile.makeupSessions,
      startDate: MemberMockProfile.packageStart,
      endDate: MemberMockProfile.packageEnd,
      trainerName: MemberMockProfile.trainerName,
      trainerSpecialty: MemberMockProfile.trainerSpecialty,
      trainerInitials: MemberMockProfile.trainerInitials,
    );
  }
}

@riverpod
PackageService packageService(PackageServiceRef ref) => const PackageService();
