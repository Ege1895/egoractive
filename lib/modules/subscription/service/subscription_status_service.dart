import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../domain/subscription_state.dart';

part 'subscription_status_service.g.dart';

/// F6-1 — `gyms/{gymId}` üzerindeki abonelik alanlarını okur. Bu alanlara
/// yazma yetkisi sadece `verifySubscriptionPurchase` callable'ında (Admin
/// SDK) var — `firestore.rules` client'ın doğrudan yazmasını engelliyor,
/// bu yüzden burada sadece bir `Stream` (okuma) sunuluyor.
class SubscriptionStatusService {
  const SubscriptionStatusService(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  Stream<SubscriptionState> watchState(String gymId) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).snapshots().map((doc) {
      final data = doc.data();
      final statusRaw = data?['subscriptionStatus'] as String?;
      final status = SubscriptionStatus.values.firstWhere(
        (s) => s.name == statusRaw,
        orElse: () => SubscriptionStatus.none,
      );
      final trialStartedAt = (data?['trialStartedAt'] as Timestamp?)?.toDate();
      final trialEndsAt = trialStartedAt?.add(Duration(days: _remoteConfig.trialDurationDays));

      return SubscriptionState(
        status: status,
        trialEndsAt: trialEndsAt,
        expiresAt: (data?['subscriptionExpiresAt'] as Timestamp?)?.toDate(),
        productId: data?['subscriptionProductId'] as String?,
      );
    });
  }
}

@riverpod
SubscriptionStatusService subscriptionStatusService(SubscriptionStatusServiceRef ref) {
  return SubscriptionStatusService(ref.watch(remoteConfigServiceProvider));
}
