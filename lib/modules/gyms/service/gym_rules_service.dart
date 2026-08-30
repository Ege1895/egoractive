import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_rules.dart';

part 'gym_rules_service.g.dart';

const _monthNamesLong = {
  1: 'Ocak',
  2: 'Şubat',
  3: 'Mart',
  4: 'Nisan',
  5: 'Mayıs',
  6: 'Haziran',
  7: 'Temmuz',
  8: 'Ağustos',
  9: 'Eylül',
  10: 'Ekim',
  11: 'Kasım',
  12: 'Aralık',
};

/// F4-5 — `gyms/{gymId}.rulesContent` (Quill Delta JSON) + `rulesUpdatedAt`.
class GymRulesService {
  const GymRulesService();

  Stream<GymRules> watchRules(String gymId) {
    return FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .snapshots()
        .map((doc) {
          final data = doc.data();
          final delta =
              data?['rulesContent'] as List<dynamic>? ?? GymRules.empty;
          final updatedAt = (data?['rulesUpdatedAt'] as Timestamp?)?.toDate();
          return GymRules(
            delta: delta,
            lastUpdatedLabel: updatedAt == null ? null : _formatDate(updatedAt),
          );
        });
  }

  Future<void> saveRules(String gymId, List<dynamic> delta) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).update({
      'rulesContent': delta,
      'rulesUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  String _formatDate(DateTime date) =>
      '${date.day} ${_monthNamesLong[date.month]} ${date.year}';
}

@riverpod
GymRulesService gymRulesService(GymRulesServiceRef ref) =>
    const GymRulesService();
