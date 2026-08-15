import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/subscription_constants.dart';
import '../domain/subscription_state.dart';

part 'subscription_purchase_service.g.dart';

/// F6-1 — `in_app_purchase` paketini sarmalar (App Store/Play Store native
/// satın alma). RevenueCat kullanılmıyor: satın alma sonucu doğrulaması
/// `verifySubscriptionPurchase` callable'ında (F6-1d) yapılır, bu servis
/// sadece mağaza API'siyle konuşur.
class SubscriptionPurchaseService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final Map<String, ProductDetails> _cache = {};

  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<SubscriptionProduct>> fetchProducts() async {
    final response = await _iap.queryProductDetails(gymSubscriptionProductIds);
    _cache
      ..clear()
      ..addEntries(response.productDetails.map((p) => MapEntry(p.id, p)));

    return response.productDetails
        .map((p) => SubscriptionProduct(id: p.id, title: p.title, description: p.description, price: p.price))
        .toList();
  }

  Future<void> buySubscription(String productId) async {
    final details = _cache[productId];
    if (details == null) {
      throw StateError('Ürün bilgisi bulunamadı, önce fetchProducts() çağrılmalı: $productId');
    }
    await _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: details));
  }

  Future<void> completePurchase(PurchaseDetails purchase) => _iap.completePurchase(purchase);
}

@riverpod
SubscriptionPurchaseService subscriptionPurchaseService(SubscriptionPurchaseServiceRef ref) {
  return SubscriptionPurchaseService();
}
