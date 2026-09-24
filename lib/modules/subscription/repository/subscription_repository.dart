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
  Future<List<SubscriptionProduct>> fetchProducts({required String locale});
  /// `true` dönerse kullanıcı mağaza sayfasını iptal etmiştir — bkz.
  /// `SubscriptionPurchaseService.buySubscription`.
  Future<bool> buySubscription(String productId);

  /// Apple Guideline 3.1.1 — geçmiş satın alımları mağazadan geri ister.
  Future<void> restorePurchases();
  Future<void> completePurchase(PurchaseDetails purchase);
  Future<void> verifyPurchase({required String gymId, required PurchaseDetails purchase});

  /// Son `fetchProducts()` çağrısı gerçek mağaza ürünü bulamayıp mock
  /// veriye mi düştü — bkz. `SubscriptionPurchaseService.lastFetchWasMock`.
  bool get lastFetchWasMock;

  Future<void> startMockSubscription({required String gymId, required String productId});
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
  Future<void> restorePurchases() => _purchaseService.restorePurchases();

  @override
  Future<bool> isAvailable() => _purchaseService.isAvailable();

  @override
  Future<List<SubscriptionProduct>> fetchProducts({required String locale}) =>
      _purchaseService.fetchProducts(locale: locale);

  @override
  Future<bool> buySubscription(String productId) => _purchaseService.buySubscription(productId);

  @override
  Future<void> completePurchase(PurchaseDetails purchase) => _purchaseService.completePurchase(purchase);

  @override
  Future<void> verifyPurchase({required String gymId, required PurchaseDetails purchase}) {
    return _verificationService.verifyPurchase(gymId: gymId, purchase: purchase);
  }

  @override
  bool get lastFetchWasMock => _purchaseService.lastFetchWasMock;

  @override
  Future<void> startMockSubscription({required String gymId, required String productId}) {
    return _verificationService.startMockSubscription(gymId: gymId, productId: productId);
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
