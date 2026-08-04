import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/studio_package.dart';
import '../repository/studio_packages_repository.dart';

part 'studio_packages_controller.g.dart';

@riverpod
class StudioPackagesController extends _$StudioPackagesController {
  @override
  List<StudioPackage> build() => ref.watch(studioPackagesRepositoryProvider).loadPackages();

  void addOrUpdate(StudioPackage package) {
    final index = state.indexWhere((p) => p.id == package.id);
    if (index == -1) {
      state = [...state, package];
    } else {
      state = [for (final p in state) p.id == package.id ? package : p];
    }
  }

  void toggleActiveForSale(String id) {
    state = [
      for (final p in state) p.id == id ? p.copyWith(activeForSale: !p.activeForSale) : p,
    ];
  }

  void deletePackage(String id) => state = state.where((p) => p.id != id).toList();
}
