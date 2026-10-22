import 'package:freezed_annotation/freezed_annotation.dart';

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

    /// F13-1 — "Satın alımları geri yükle" akışı sürüyor mu.
    @Default(false) bool isRestoring,

    /// Geri yükleme akışının SONUCU (başarılı / satın alım bulunamadı /
    /// hata). [purchaseErrorMessage]'dan ayrı tutuluyor: geri yüklemede
    /// "bulunamadı" bir hata değil, bilgilendirme.
    String? restoreMessage,

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

    /// Mağazadan (App Store Connect'teki Introductory Offer → Free Trial)
    /// okunan gerçek ücretsiz deneme süresi (gün) — bkz.
    /// `SubscriptionPurchaseService.fetchProducts`. Mağazada bu ürün için
    /// ücretsiz deneme tanımlı değilse (ya da henüz okunamıyorsa, örn.
    /// Android/Play Console kurulumu tamamlanmadan) `null` kalır; ekran bu
    /// durumda Remote Config'teki sabit metne düşer — hardcode edilmiş bir
    /// süre asla gösterilmez.
    int? trialDays,
  }) = _SubscriptionProduct;
}
