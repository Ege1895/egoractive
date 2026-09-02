import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_rules.dart';
import '../../../shared/utils/date_labels.dart';

part 'gym_rules_service.g.dart';

/// F4-5 — `gyms/{gymId}.rulesContent` (Quill Delta JSON) + `rulesUpdatedAt`.
class GymRulesService {
  const GymRulesService();

  Stream<GymRules> watchRules(String gymId, DateLabels labels) {
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
            lastUpdatedLabel: updatedAt == null
                ? null
                : labels.dayMonthYearLong(updatedAt),
          );
        });
  }

  Future<void> saveRules(String gymId, List<dynamic> delta) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).update({
      'rulesContent': delta,
      'rulesUpdatedAt': FieldValue.serverTimestamp(),
    });
  }
}

@riverpod
GymRulesService gymRulesService(GymRulesServiceRef ref) =>
    const GymRulesService();
