import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/member_package.dart';
import '../service/package_service.dart';

part 'package_repository.g.dart';

abstract interface class PackageRepository {
  MemberPackage loadActivePackage();
}

class PackageRepositoryImpl implements PackageRepository {
  const PackageRepositoryImpl(this._service);

  final PackageService _service;

  @override
  MemberPackage loadActivePackage() => _service.loadActivePackage();
}

@riverpod
PackageRepository packageRepository(PackageRepositoryRef ref) {
  return PackageRepositoryImpl(ref.watch(packageServiceProvider));
}
