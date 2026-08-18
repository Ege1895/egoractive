import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../service/package_service.dart';

part 'package_repository.g.dart';

abstract interface class PackageRepository {
  Stream<Map<String, dynamic>?> watchMemberDoc(String memberId);
  Stream<Map<String, dynamic>?> watchLatestPackageDoc(String memberId);
  Future<String> loadTrainerSpecialty(String trainerId);
}

class PackageRepositoryImpl implements PackageRepository {
  const PackageRepositoryImpl(this._service);

  final PackageService _service;

  @override
  Stream<Map<String, dynamic>?> watchMemberDoc(String memberId) =>
      _service.watchMemberDoc(memberId);

  @override
  Stream<Map<String, dynamic>?> watchLatestPackageDoc(String memberId) =>
      _service.watchLatestPackageDoc(memberId);

  @override
  Future<String> loadTrainerSpecialty(String trainerId) =>
      _service.loadTrainerSpecialty(trainerId);
}

@riverpod
PackageRepository packageRepository(PackageRepositoryRef ref) {
  return PackageRepositoryImpl(ref.watch(packageServiceProvider));
}
