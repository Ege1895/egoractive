import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
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
  static const _productQueryTimeout = Duration(seconds: 15);

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

  Stream<List<PurchaseDetails>> get purchaseUpdates => _iap.purchaseStream;

  Future<bool> isAvailable() => _iap.isAvailable();

  /// F13-1 — mağazanın, bu hesabın geçmiş/geçerli satın alımlarını yeniden
  /// `purchaseStream`'e sunmasını ister. Sonuç bu çağrının dönüşünde DEĞİL,
  /// stream'e düşen `PurchaseStatus.restored` olaylarında gelir; hiç satın
  /// alım yoksa stream'e HİÇBİR ŞEY düşmez (bkz. `SubscriptionController`
  /// bunu bir zaman aşımıyla ele alıyor).
  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<List<SubscriptionProduct>> fetchProducts({
    required String locale,
  }) async {
    // Mağaza servisine hiç ulaşılamazsa (ör. Play Store'u olmayan cihaz,
    // bağlantı kopukluğu) sorgu HİÇ dönmüyor ve ekran sonsuza kadar
    // yükleniyordu. Zaman aşımında da "Tekrar dene" durumuna düşülür.
    final response = await _iap
        .queryProductDetails(gymSubscriptionProductIds)
        .timeout(
          _productQueryTimeout,
          onTimeout: () =>
              throw const SubscriptionProductsUnavailableException('timeout'),
        );
    // Play, bir aboneliğin base plan'ını ve her teklifini (ör. 14 günlük
    // ücretsiz deneme) AYRI bir ürün kaydı olarak döndürüyor; teklif
    // tanımlanınca ekranda aynı plan iki kez (biri "Ücretsiz" fiyatlı)
    // çıkıyor ve hangi teklifin satın alınacağı belirsiz kalıyordu. Her
    // abonelik için tek kayıt seçilir (bkz. [_pickAndroidOffer]).
    final products = _onePerProduct(response.productDetails);
    _cache
      ..clear()
      ..addEntries(products.map((p) => MapEntry(p.id, p)));

    // Mağaza ürün döndürmezse (bağlantı hatası, ürün yapılandırması ya da
    // bölge uygunluğu eksik, Paid Apps Agreement yürürlükte değil) ekranda
    // sahte plan göstermek yerine hata fırlatılır; abonelik ekranları bunu
    // "tekrar dene" durumu olarak gösterir. Önceden burada mock planlar
    // dönüyordu ve plana dokunmak ödeme almadan deneme başlatıyordu —
    // Apple incelemesinde "plana dokununca hiçbir şey olmadı" reddine yol
    // açtı (2026-10-21).
    if (response.error != null || response.productDetails.isEmpty) {
      throw SubscriptionProductsUnavailableException(
        response.error?.message ??
            'notFound: ${response.notFoundIDs.join(', ')}',
      );
    }

    return products.map(toSubscriptionProduct).toList();
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
      throw StateError(
        'Ürün bilgisi bulunamadı, önce fetchProducts() çağrılmalı: $productId',
      );
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

  Future<void> completePurchase(PurchaseDetails purchase) =>
      _iap.completePurchase(purchase);
}

/// Mağaza ürünlerini ekranda gösterilecek abonelik listesine çevirir:
/// Android'de her abonelik için tek teklif seçilir, fiyat yenilenme
/// fiyatıdır, deneme süresi seçilen tekliften okunur.
@visibleForTesting
List<ProductDetails> selectSubscriptionOffers(List<ProductDetails> all) =>
    _onePerProduct(all);

@visibleForTesting
SubscriptionProduct toSubscriptionProduct(ProductDetails p) =>
    SubscriptionProduct(
      id: p.id,
      title: p.title,
      description: p.description,
      price: _recurringPrice(p),
      trialDays: _freeTrialDays(p),
    );

/// iOS'ta her abonelik zaten tek kayıttır. Android'de aynı abonelik için
/// gelen kayıtlardan [_pickAndroidOffer] ile biri seçilir.
List<ProductDetails> _onePerProduct(List<ProductDetails> all) {
  final byId = <String, List<ProductDetails>>{};
  for (final p in all) {
    byId.putIfAbsent(p.id, () => []).add(p);
  }
  return [
    for (final offers in byId.values)
      offers.length == 1 ? offers.single : _pickAndroidOffer(offers),
  ];
}

/// Play yalnızca kullanıcının UYGUN olduğu teklifleri döndürür; bu yüzden
/// listede ücretsiz deneme teklifi varsa kullanıcı denemeye uygundur ve
/// o seçilir (Play penceresi "14 gün ücretsiz, sonra …" gösterir). Yoksa
/// (ör. daha önce abone olmuş hesap) teklifsiz base plan seçilir.
ProductDetails _pickAndroidOffer(List<ProductDetails> offers) {
  final google = offers.whereType<GooglePlayProductDetails>().toList();
  final freeTrial = google.where((p) => _freeTrialPhase(p) != null);
  if (freeTrial.isNotEmpty) return freeTrial.first;
  final basePlan = google.where((p) => _offerOf(p)?.offerId == null);
  return basePlan.isNotEmpty ? basePlan.first : offers.first;
}

SubscriptionOfferDetailsWrapper? _offerOf(GooglePlayProductDetails p) {
  final index = p.subscriptionIndex;
  final offers = p.productDetails.subscriptionOfferDetails;
  if (index == null || offers == null || index >= offers.length) return null;
  return offers[index];
}

PricingPhaseWrapper? _freeTrialPhase(GooglePlayProductDetails p) {
  final phases = _offerOf(p)?.pricingPhases ?? const [];
  if (phases.length < 2 || phases.first.priceAmountMicros != 0) return null;
  return phases.first;
}

/// Planın kartta gösterilecek fiyatı. Android'de deneme teklifinin ilk
/// aşaması "Ücretsiz" olduğu için yenilenen (son) aşamanın fiyatı
/// kullanılır; iOS'ta ürün fiyatı zaten yenilenme fiyatıdır.
String _recurringPrice(ProductDetails p) {
  if (p is GooglePlayProductDetails) {
    final phases = _offerOf(p)?.pricingPhases;
    if (phases != null && phases.isNotEmpty) {
      return phases.last.formattedPrice;
    }
  }
  return p.price;
}

/// Mağazada bu ürün için tanımlı ücretsiz deneme (Introductory Offer →
/// Free Trial) varsa gün cinsinden süresini döner — bulunamazsa `null`
/// (ekran bu durumda RC'deki sabit metne düşer, bkz. `SubscriptionProduct`
/// yorumu). Android'de seçilen teklifin sıfır fiyatlı ilk aşamasından,
/// iOS'ta StoreKit2'nin tanıtım teklifinden okunur.
int? _freeTrialDays(ProductDetails product) {
  if (product is GooglePlayProductDetails) {
    final phase = _freeTrialPhase(product);
    return phase == null ? null : _isoPeriodDays(phase.billingPeriod);
  }
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

/// Play'in ISO 8601 süre biçimi (P14D, P2W, P1M, P1Y) → gün.
int? _isoPeriodDays(String period) {
  final match = RegExp(r'^P(\d+)([DWMY])$').firstMatch(period);
  if (match == null) return null;
  final value = int.parse(match.group(1)!);
  return switch (match.group(2)) {
    'D' => value,
    'W' => value * 7,
    'M' => value * 30,
    _ => value * 365,
  };
}

@riverpod
SubscriptionPurchaseService subscriptionPurchaseService(
  SubscriptionPurchaseServiceRef ref,
) {
  return SubscriptionPurchaseService();
}

/// Mağazadan abonelik ürünleri alınamadığında `fetchProducts` bunu fırlatır.
class SubscriptionProductsUnavailableException implements Exception {
  const SubscriptionProductsUnavailableException(this.reason);

  final String reason;

  @override
  String toString() => 'SubscriptionProductsUnavailableException: $reason';
}
