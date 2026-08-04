import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/studio_package.dart';

part 'studio_packages_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}/packages` koleksiyonuna
/// bağlanacak.
class StudioPackagesService {
  const StudioPackagesService();

  List<StudioPackage> loadPackages() {
    return const [
      StudioPackage(id: 'birebir-8', name: 'Birebir 8 Seans', sessionType: PackageSessionType.solo, sessionCount: 8, validityDays: 60, priceTl: 9600),
      StudioPackage(id: 'birebir-12', name: 'Birebir 12 Seans', sessionType: PackageSessionType.solo, sessionCount: 12, validityDays: 90, priceTl: 14400),
      StudioPackage(id: 'birebir-20', name: 'Birebir 20 Seans', sessionType: PackageSessionType.solo, sessionCount: 20, validityDays: 120, priceTl: 22000),
      StudioPackage(id: 'grup-12', name: 'Grup 12 Seans', sessionType: PackageSessionType.group, sessionCount: 12, validityDays: 90, priceTl: 6000),
      StudioPackage(id: 'grup-24', name: 'Grup 24 Seans', sessionType: PackageSessionType.group, sessionCount: 24, validityDays: 180, priceTl: 10800, activeForSale: false),
    ];
  }
}

@riverpod
StudioPackagesService studioPackagesService(StudioPackagesServiceRef ref) => const StudioPackagesService();
