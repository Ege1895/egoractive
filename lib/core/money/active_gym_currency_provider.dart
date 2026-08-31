import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/currency_constants.dart';
import '../theme/theme_controller.dart';

part 'active_gym_currency_provider.g.dart';

/// F9-3 — para gösterilen/girilen HER ekranın aktif salonun para birimini
/// okumak için kullandığı tek kaynak. `GymProfileController` salon profili
/// DÜZENLEME akışının (form state, reset() vb.) parçası olduğundan, sadece
/// bir sayıyı doğru para biriminde göstermek isteyen ekranların ona bağımlı
/// olmaması için ayrı, salt-okunur bir provider.
@riverpod
Stream<String> activeGymCurrency(ActiveGymCurrencyRef ref) async* {
  final gymId = await ref.watch(activeGymIdProvider.future);
  if (gymId == null) {
    yield defaultCurrencyCode;
    return;
  }
  yield* FirebaseFirestore.instance
      .collection('gyms')
      .doc(gymId)
      .snapshots()
      .map(
        (doc) => (doc.data()?['currency'] as String?) ?? defaultCurrencyCode,
      );
}
