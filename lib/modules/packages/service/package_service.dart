import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_service.g.dart';

class PackageService {
  const PackageService();

  Stream<Map<String, dynamic>?> watchMemberDoc(String memberId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(memberId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// `memberPackages`'te tek bir üye için birden fazla doküman birikebilir
  /// (her yenilemede yeni bir doküman yazılıyor, bkz.
  /// `NewMembershipController.save`) — en son satın alınan paket
  /// `purchasedAt`'e göre alınır.
  Stream<Map<String, dynamic>?> watchLatestPackageDoc(String memberId) {
    return FirebaseFirestore.instance
        .collection('memberPackages')
        .where('memberId', isEqualTo: memberId)
        .orderBy('purchasedAt', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.isEmpty ? null : snapshot.docs.first.data(),
        );
  }

  Future<String> loadTrainerSpecialty(String trainerId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(trainerId)
        .get();
    final specialties =
        (doc.data()?['specialties'] as List?)?.whereType<String>().toList() ??
        const [];
    return specialties.isEmpty ? '' : specialties.first;
  }
}

@riverpod
PackageService packageService(PackageServiceRef ref) => const PackageService();
