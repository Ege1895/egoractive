import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/studio_package.dart';
import '../service/studio_packages_service.dart';

part 'studio_packages_repository.g.dart';

abstract interface class StudioPackagesRepository {
  List<StudioPackage> loadPackages();
}

class StudioPackagesRepositoryImpl implements StudioPackagesRepository {
  const StudioPackagesRepositoryImpl(this._service);

  final StudioPackagesService _service;

  @override
  List<StudioPackage> loadPackages() => _service.loadPackages();
}

@riverpod
StudioPackagesRepository studioPackagesRepository(StudioPackagesRepositoryRef ref) {
  return StudioPackagesRepositoryImpl(ref.watch(studioPackagesServiceProvider));
}
