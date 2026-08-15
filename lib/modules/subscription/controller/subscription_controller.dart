import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/subscription_state.dart';
import '../repository/subscription_repository.dart';

part 'subscription_controller.g.dart';

@riverpod
Stream<SubscriptionState> _subscriptionStateForGym(_SubscriptionStateForGymRef ref, String gymId) {
  return ref.watch(subscriptionRepositoryProvider).watchState(gymId);
}

/// F6-1 — aktif salonun abonelik durumunu okur ve mağaza satın alma akışını
/// başlatır. Satın alma tamamlandığında `verifySubscriptionPurchase`
/// callable'ını (F6-1d) çağırıp makbuzu doğrulatır — `gyms/{gymId}`'nin
/// abonelik alanlarını bu Controller ASLA doğrudan yazmaz (firestore.rules
/// zaten client yazımını engelliyor).
@riverpod
class SubscriptionController extends _$SubscriptionController {
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  @override
  SubscriptionState build() {
    ref.onDispose(() => _purchaseSub?.cancel());
    _purchaseSub ??= ref.watch(subscriptionRepositoryProvider).purchaseUpdates.listen(_onPurchaseUpdate);

    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return const SubscriptionState();
    return ref.watch(_subscriptionStateForGymProvider(gymId)).valueOrNull ?? const SubscriptionState();
  }

  Future<List<SubscriptionProduct>> fetchProducts() => ref.read(subscriptionRepositoryProvider).fetchProducts();

  Future<void> purchase(String productId) async {
    if (state.isPurchasing) return;
    state = state.copyWith(isPurchasing: true);
    try {
      await ref.read(subscriptionRepositoryProvider).buySubscription(productId);
    } finally {
      state = state.copyWith(isPurchasing: false);
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    final gymId = ref.read(activeGymIdProvider).valueOrNull;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        if (gymId != null) {
          await repo.verifyPurchase(gymId: gymId, purchase: purchase);
        }
        await repo.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error || purchase.status == PurchaseStatus.canceled) {
        await repo.completePurchase(purchase);
      }
    }
  }
}
