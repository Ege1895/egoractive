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

  /// Son `fetchProducts()` çağrısı mağazadan gerçek ürün alamayıp
  /// [mockSubscriptionProducts]'a düştü mü — `SubscriptionOnboardingPanel`
  /// bunu görüp CTA'yı gerçek satın alma yerine `startMockSubscription`
  /// callable'ına yönlendirir (bkz. o dosyadaki yorum). Mağaza gerçek ürün
  /// döndürmeye başlar başlamaz bu otomatik olarak `false` olur.
  bool lastFetchWasMock = false;

  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  Future<List<SubscriptionProduct>> fetchProducts({required String locale}) async {
    final response = await _iap.queryProductDetails(gymSubscriptionProductIds);
    _cache
      ..clear()
      ..addEntries(response.productDetails.map((p) => MapEntry(p.id, p)));

    lastFetchWasMock = response.productDetails.isEmpty;
    if (lastFetchWasMock) {
      // Mağaza ürünleri henüz App Store Connect/Play Console'da
      // yayınlanmadıysa (bkz. docs/Abonelik_Store_Kurulumu.md) gerçek bir
      // yanıt hiç gelmez — ekran boş kalıp test/inceleme için kullanılamaz
      // hale gelirdi. `_cache` boş bırakılır (mock ürünler için satın alma
      // denemesi zaten `buySubscription`'da StateError ile güvenle
      // reddedilir), sadece görüntüleme için sahte veri döndürülür.
      return mockSubscriptionProducts(locale);
    }

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
