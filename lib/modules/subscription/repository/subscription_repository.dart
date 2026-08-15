import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/subscription_state.dart';
import '../service/subscription_purchase_service.dart';
import '../service/subscription_status_service.dart';
import '../service/subscription_verification_service.dart';

part 'subscription_repository.g.dart';

abstract interface class SubscriptionRepository {
  Stream<SubscriptionState> watchState(String gymId);
  Stream<List<PurchaseDetails>> get purchaseUpdates;
  Future<bool> isAvailable();
  Future<List<SubscriptionProduct>> fetchProducts();
  Future<void> buySubscription(String productId);
  Future<void> completePurchase(PurchaseDetails purchase);
  Future<void> verifyPurchase({required String gymId, required PurchaseDetails purchase});
}

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  const SubscriptionRepositoryImpl(this._statusService, this._purchaseService, this._verificationService);

  final SubscriptionStatusService _statusService;
  final SubscriptionPurchaseService _purchaseService;
  final SubscriptionVerificationService _verificationService;

  @override
  Stream<SubscriptionState> watchState(String gymId) => _statusService.watchState(gymId);

  @override
  Stream<List<PurchaseDetails>> get purchaseUpdates => _purchaseService.purchaseUpdates;

  @override
  Future<bool> isAvailable() => _purchaseService.isAvailable();

  @override
  Future<List<SubscriptionProduct>> fetchProducts() => _purchaseService.fetchProducts();

  @override
  Future<void> buySubscription(String productId) => _purchaseService.buySubscription(productId);

  @override
  Future<void> completePurchase(PurchaseDetails purchase) => _purchaseService.completePurchase(purchase);

  @override
  Future<void> verifyPurchase({required String gymId, required PurchaseDetails purchase}) {
    return _verificationService.verifyPurchase(gymId: gymId, purchase: purchase);
  }
}

@riverpod
SubscriptionRepository subscriptionRepository(SubscriptionRepositoryRef ref) {
  return SubscriptionRepositoryImpl(
    ref.watch(subscriptionStatusServiceProvider),
    ref.watch(subscriptionPurchaseServiceProvider),
    ref.watch(subscriptionVerificationServiceProvider),
  );
}
