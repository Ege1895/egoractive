import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/constants/subscription_constants.dart';

part 'subscription_state.freezed.dart';

/// F6-1 — `gyms/{gymId}.subscriptionStatus`'ın olası değerleri. `pastDue`/
/// `canceled` — Salon Abonelik ve Erişim Akışı: sadece `trial`/`active`
/// erişime izin verir, ikisi de (expired ile birlikte) engellenir.
enum SubscriptionStatus { trial, active, pastDue, canceled, expired, none }

@freezed
class SubscriptionState with _$SubscriptionState {
  const factory SubscriptionState({
    @Default(SubscriptionStatus.none) SubscriptionStatus status,
    DateTime? trialStartedAt,
    DateTime? trialEndsAt,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? productId,
    @Default(false) bool isPurchasing,

    /// Salon daha önce (herhangi bir admin/hesapla) hiç trial kullandı mı —
    /// bir kez `true` olunca kalıcıdır, salon bir daha ücretsiz deneme
    /// alamaz (bkz. `apply-subscription-update.ts`).
    @Default(false) bool trialUsed,

    /// `gyms/{gymId}.subscriptionExempt` — sadece Firebase Console/Admin
    /// SDK'dan elle set edilen bir bayrak (client hiç yazamaz, bkz.
    /// firestore.rules `subscriptionFields()`). `true` iken bu salon
    /// abonelik durumu ne olursa olsun (hatta `none`/`expired` iken bile)
    /// tam erişimli sayılır — test/demo salonları için ödeme almadan aktif
    /// tutma amaçlı.
    @Default(false) bool subscriptionExempt,

    /// Satın alma akışı başlatılan ürün — mağaza penceresi açıkken hangi
    /// plan kartının "bekleniyor" durumunda gösterileceğini belirler.
    String? pendingProductId,

    /// Satın alma hatası (network, mağaza reddi, doğrulama başarısızlığı).
    /// Kullanıcı kendi isteğiyle iptal ederse (`PurchaseStatus.canceled`)
    /// bu alan boş kalır — o zaten kendi kararı, hata değil.
    String? purchaseErrorMessage,
  }) = _SubscriptionState;
}

/// Bir mağaza (App Store/Play Store) satın alınabilir aboneliğinin özeti —
/// `in_app_purchase` paketinin `ProductDetails`'ından bağımsız, UI'ın
/// ihtiyaç duyduğu alanlara indirgenmiş hali.
@freezed
class SubscriptionProduct with _$SubscriptionProduct {
  const factory SubscriptionProduct({
    required String id,
    required String title,
    required String description,
    required String price,
  }) = _SubscriptionProduct;
}

/// Mağaza ürünleri henüz App Store Connect/Play Console'da yayınlanmadıysa
/// (bkz. docs/Abonelik_Store_Kurulumu.md) `SubscriptionPurchaseService.fetchProducts()`
/// gerçek yanıt yerine bunu döner — abonelik ekranları böylece boş kalmaz,
/// görüntülenip test edilebilir. Bu ürünlerle gerçek satın alma denemesi
/// (mağazada karşılığı olmadığı için) güvenle başarısız olur.
final mockSubscriptionProducts = [
  const SubscriptionProduct(
    id: gymMonthlySubscriptionProductId,
    title: 'Aylık',
    description: 'Her ay yenilenir',
    price: '₺299,99',
  ),
  const SubscriptionProduct(
    id: gymYearlySubscriptionProductId,
    title: 'Yıllık',
    description: '2 ay bedava',
    price: '₺2.999,99',
  ),
];
