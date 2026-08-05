import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/studio_package.dart';
import '../repository/studio_packages_repository.dart';

part 'studio_packages_controller.g.dart';

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [StudioPackagesController] mock repository'e düşer.
@riverpod
Stream<List<StudioPackage>> _packagesForGym(_PackagesForGymRef ref, String gymId) {
  return FirebaseFirestore.instance
      .collection('gyms')
      .doc(gymId)
      .collection('packages')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_toPackage).toList());
}

StudioPackage _toPackage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  return StudioPackage(
    id: doc.id,
    name: (data['name'] as String?) ?? '',
    sessionType: (data['sessionType'] as String?) == 'group' ? PackageSessionType.group : PackageSessionType.solo,
    sessionCount: (data['sessionCount'] as num?)?.toInt() ?? 0,
    validityDays: (data['validityDays'] as num?)?.toInt() ?? 0,
    priceTl: (data['priceTl'] as num?)?.toInt() ?? 0,
    activeForSale: (data['activeForSale'] as bool?) ?? true,
  );
}

Map<String, dynamic> _toFirestoreMap(StudioPackage package) {
  return {
    'name': package.name,
    'sessionType': package.sessionType.name,
    'sessionCount': package.sessionCount,
    'validityDays': package.validityDays,
    'priceTl': package.priceTl,
    'activeForSale': package.activeForSale,
  };
}

/// F3-1 — stüdyo paket kataloğu artık gerçek zamanlı `gyms/{gymId}/packages`
/// koleksiyonundan okunur/yazılır. Dış arayüz bilerce senkron
/// (`List<StudioPackage>`) tutuldu — panel tüketicileri `AsyncValue` bilmek
/// zorunda değil.
@riverpod
class StudioPackagesController extends _$StudioPackagesController {
  @override
  List<StudioPackage> build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      return ref.watch(studioPackagesRepositoryProvider).loadPackages();
    }
    return ref.watch(_packagesForGymProvider(gymId)).valueOrNull ?? const [];
  }

  Future<void> addOrUpdate(StudioPackage package) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .collection('packages')
        .doc(package.id)
        .set(_toFirestoreMap(package));
  }

  Future<void> toggleActiveForSale(String id) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    final matches = state.where((p) => p.id == id);
    if (gymId == null || matches.isEmpty) return;
    final package = matches.first;
    await FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .collection('packages')
        .doc(id)
        .update({'activeForSale': !package.activeForSale});
  }

  Future<void> deletePackage(String id) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await FirebaseFirestore.instance.collection('gyms').doc(gymId).collection('packages').doc(id).delete();
  }
}
