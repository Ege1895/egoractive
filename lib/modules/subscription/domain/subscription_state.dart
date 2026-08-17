import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_state.freezed.dart';

/// F6-1 — `gyms/{gymId}.subscriptionStatus`'ın olası değerleri.
enum SubscriptionStatus { trial, active, expired, none }

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
    /// Satın alma akışı başlatılan ürün — mağaza penceresi açıkken hangi
    /// plan kartının "bekleniyor" durumunda gösterileceğini belirler.
    String? pendingProductId,
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
