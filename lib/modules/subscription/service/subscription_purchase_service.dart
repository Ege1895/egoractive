import 'dart:io' show Platform;

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart' as sk2;
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

  /// F13-7 — Android'de yükseltme (aylık → yıllık) için GEREKLİ olan mevcut
  /// satın alma kayıtları, ürün kimliğine göre.
  ///
  /// Play, farklı bir ürün kimliği satın alındığında bunu kendiliğinden bir
  /// "plan değişikliği" saymaz; eski satın almanın token'ı açıkça
  /// gönderilmezse salon İKİ aboneliğe birden sahip olur ve iki kez
  /// ücretlendirilir. Token'a ulaşmanın tek yolu `purchaseStream`'e düşen
  /// [PurchaseDetails] nesneleri olduğu için burada tutuluyor.
  final Map<String, GooglePlayPurchaseDetails> _androidPurchases = {};

  /// Son `fetchProducts()` çağrısı mağazadan gerçek ürün alamayıp
  /// [mockSubscriptionProducts]'a düştü mü — `SubscriptionOnboardingPanel`
  /// bunu görüp CTA'yı gerçek satın alma yerine `startMockSubscription`
  /// callable'ına yönlendirir (bkz. o dosyadaki yorum). Mağaza gerçek ürün
  /// döndürmeye başlar başlamaz bu otomatik olarak `false` olur.
  bool lastFetchWasMock = false;

  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  /// F13-1 — mağazanın, bu hesabın geçmiş/geçerli satın alımlarını yeniden
  /// `purchaseStream`'e sunmasını ister. Sonuç bu çağrının dönüşünde DEĞİL,
  /// stream'e düşen `PurchaseStatus.restored` olaylarında gelir; hiç satın
  /// alım yoksa stream'e HİÇBİR ŞEY düşmez (bkz. `SubscriptionController`
  /// bunu bir zaman aşımıyla ele alıyor).
  Future<void> restorePurchases() => _iap.restorePurchases();

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
        .map(
          (p) => SubscriptionProduct(
            id: p.id,
            title: p.title,
            description: p.description,
            price: p.price,
            trialDays: _freeTrialDays(p),
          ),
        )
        .toList();
  }

  /// Mağazada bu ürün için tanımlı ücretsiz deneme (Introductory Offer →
  /// Free Trial) varsa gün cinsinden süresini döner — bulunamazsa `null`
  /// (ekran bu durumda RC'deki sabit metne düşer, bkz. `SubscriptionProduct`
  /// yorumu). Şu an sadece iOS/StoreKit2 destekleniyor: Android/Play
  /// Billing tarafı, Play Console kurulumu tamamlanmadan (henüz gerçek
  /// ürün dönmediği için) test edilemiyor — kurulum bittiğinde
  /// `GooglePlayProductDetails.productDetails.subscriptionOfferDetails`
  /// üzerinden (sıfır fiyatlı `pricingPhase`) benzer şekilde eklenmeli.
  int? _freeTrialDays(ProductDetails product) {
    if (product is! AppStoreProduct2Details) return null;
    final offers = product.sk2Product.subscription?.promotionalOffers ?? const [];
    final freeTrial = offers
        .where(
          (o) =>
              o.type == sk2.SK2SubscriptionOfferType.introductory &&
              o.paymentMode == sk2.SK2SubscriptionOfferPaymentMode.freeTrial,
        )
        .firstOrNull;
    if (freeTrial == null) return null;
    final unitDays = switch (freeTrial.period.unit) {
      sk2.SK2SubscriptionPeriodUnit.day => 1,
      sk2.SK2SubscriptionPeriodUnit.week => 7,
      sk2.SK2SubscriptionPeriodUnit.month => 30,
      sk2.SK2SubscriptionPeriodUnit.year => 365,
    };
    return freeTrial.period.value * unitDays;
  }

  /// `true` dönerse kullanıcı mağaza sayfasını iptal etmiştir (çağıran taraf
  /// bekleme durumunu hemen sıfırlayabilir); `false` ise satın alma
  /// sürüyordur/tamamlanmıştır — sonucu her zamanki gibi [purchaseUpdates]
  /// akışından bekle.
  /// `purchaseStream`'e düşen her satın almayı önbelleğe alır — yükseltmede
  /// eski aboneliğin token'ı buradan okunuyor. iOS'ta gerek yok: aynı
  /// abonelik grubundaki ürünler arasında geçişi StoreKit kendisi yönetiyor.
  void rememberPurchase(PurchaseDetails purchase) {
    if (purchase is! GooglePlayPurchaseDetails) return;
    if (!gymSubscriptionProductIds.contains(purchase.productID)) return;
    if (purchase.status != PurchaseStatus.purchased &&
        purchase.status != PurchaseStatus.restored) {
      return;
    }
    _androidPurchases[purchase.productID] = purchase;
  }

  /// [productId] DIŞINDAKİ salon aboneliklerinden önbellekte olanı döner —
  /// yani "yükseltirken devredilecek eski abonelik".
  GooglePlayPurchaseDetails? androidPurchaseToReplace(String productId) {
    for (final entry in _androidPurchases.entries) {
      if (entry.key != productId) return entry.value;
    }
    return null;
  }

  Future<bool> buySubscription(
    String productId, {
    GooglePlayPurchaseDetails? replacing,
  }) async {
    final details = _cache[productId];
    if (details == null) {
      throw StateError('Ürün bilgisi bulunamadı, önce fetchProducts() çağrılmalı: $productId');
    }
    if (Platform.isIOS) {
      // `InAppPurchase.buyNonConsumable`, StoreKit2 altyapısında native
      // `Product.purchase()` çağrısının gerçek sonucunu (userCancelled/
      // pending/success) tamamen atıp her zaman `true` döner — StoreKit2'de
      // bir Transaction sadece gerçek satın almada oluştuğundan, kullanıcı
      // mağaza sayfasını iptal ettiğinde [purchaseUpdates]'e HİÇ olay
      // düşmez. Bu yüzden StoreKit2 API'sini burada doğrudan çağırıp gerçek
      // sonucu okuyoruz — bu, `buyNonConsumable`'ın kendi içinde zaten
      // yaptığı native çağrının birebir aynısı (paketin transaction
      // observer'ı ayrı bir mekanizma, native `Transaction.updates`
      // sequence'ini dinliyor; burada ikinci bir satın alma BAŞLATMIYORUZ,
      // sadece aynı çağrının sonucunu okuyoruz), o yüzden çift satın alma
      // riski yok.
      final result = await sk2.SK2Product.purchase(productId);
      return result == sk2.SK2ProductPurchaseResult.userCancelled;
    }
    // F13-7 — `replacing` doluysa bu bir YÜKSELTME: eski satın alma token'ı
    // Play'e devrediliyor, böylece Play eskisini kapatıp yenisini açıyor.
    // `chargeFullPrice`, Play Console'daki "Ödemeyi hemen al" ayarının
    // karşılığı: yeni planın tamamı hemen tahsil edilir, eski plandan kalan
    // süre krediye eklenir.
    await _iap.buyNonConsumable(
      purchaseParam: replacing == null
          ? PurchaseParam(productDetails: details)
          : GooglePlayPurchaseParam(
              productDetails: details,
              changeSubscriptionParam: ChangeSubscriptionParam(
                oldPurchaseDetails: replacing,
                replacementMode: ReplacementMode.chargeFullPrice,
              ),
            ),
    );
    return false;
  }

  Future<void> completePurchase(PurchaseDetails purchase) => _iap.completePurchase(purchase);
}

@riverpod
SubscriptionPurchaseService subscriptionPurchaseService(SubscriptionPurchaseServiceRef ref) {
  return SubscriptionPurchaseService();
}
