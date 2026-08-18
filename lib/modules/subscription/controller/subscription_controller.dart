import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/subscription_state.dart';
import '../repository/subscription_repository.dart';

part 'subscription_controller.g.dart';

@riverpod
Stream<SubscriptionState> _subscriptionStateForGym(
  _SubscriptionStateForGymRef ref,
  String gymId,
) {
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

  // Firestore'dan gelen her yeni doküman anlık görüntüsü build()'i tekrar
  // çalıştırıp SubscriptionState'i sıfırdan üretiyor — isPurchasing/
  // pendingProductId bu akışın parçası değil (gyms/{gymId} dokümanında
  // yok), bu yüzden ayrı örnek alanlarında tutulup her build()'de geri
  // bindiriliyor; yoksa satın alma sürerken gelen alakasız bir Firestore
  // güncellemesi "mağaza bekleniyor" ekranını sıfırlardı.
  bool _isPurchasing = false;
  String? _pendingProductId;

  @override
  SubscriptionState build() {
    ref.onDispose(() => _purchaseSub?.cancel());
    _purchaseSub ??= ref
        .watch(subscriptionRepositoryProvider)
        .purchaseUpdates
        .listen(_onPurchaseUpdate);

    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    final base = gymId == null
        ? const SubscriptionState()
        : ref.watch(_subscriptionStateForGymProvider(gymId)).valueOrNull ??
              const SubscriptionState();
    return base.copyWith(
      isPurchasing: _isPurchasing,
      pendingProductId: _pendingProductId,
    );
  }

  Future<List<SubscriptionProduct>> fetchProducts() =>
      ref.read(subscriptionRepositoryProvider).fetchProducts();

  /// `isPurchasing`, satın alma sadece başlatılırken değil — mağaza
  /// penceresi açıkken sonuç [_onPurchaseUpdate] üzerinden gelene kadar
  /// (satın alındı/geri yüklendi/hata/iptal) `true` kalır, ekran "mağaza
  /// bekleniyor" durumunu bu süre boyunca göstersin diye.
  /// Önceki sürüm hatayı tamamen yutuyordu — kullanıcı parasının gidip
  /// gitmediğini, işlemin neden tamamlanmadığını hiç öğrenemiyordu. Artık
  /// hem başlatma hatası hem de mağazadan dönen `error` durumu bir mesaj
  /// olarak gösteriliyor; kullanıcının kendi iptali (`canceled`) sessiz
  /// kalmaya devam ediyor çünkü o zaten kendi kararı.
  Future<void> purchase(String productId) async {
    if (_isPurchasing) return;
    _isPurchasing = true;
    _pendingProductId = productId;
    state = state.copyWith(
      isPurchasing: true,
      pendingProductId: productId,
      purchaseErrorMessage: null,
    );
    try {
      await ref.read(subscriptionRepositoryProvider).buySubscription(productId);
    } catch (_) {
      _isPurchasing = false;
      _pendingProductId = null;
      state = state.copyWith(
        isPurchasing: false,
        pendingProductId: null,
        purchaseErrorMessage:
            'Satın alma başlatılamadı, mağaza bağlantısını kontrol edip tekrar dene.',
      );
    }
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    final gymId = ref.read(activeGymIdProvider).valueOrNull;

    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // verifyPurchase (Cloud Functions) ağ/sunucu hatasıyla başarısız
        // olabilir — önceden bu durumda ne completePurchase çağrılıyordu
        // (StoreKit/Play Billing işlemi "pending" kalıp bir sonraki açılışta
        // tekrar sunuluyordu) ne de isPurchasing false'a dönüyordu (kullanıcı
        // "mağaza bekleniyor" ekranında sonsuza kadar kalıyordu). Ödeme
        // mağazada zaten gerçekleşmiş olduğu için doğrulama başarısız olsa
        // bile işlem her zaman tamamlanır (finish edilir); kullanıcıya
        // ayrıca bir hata gösterilir.
        String? verifyErrorMessage;
        if (gymId != null) {
          try {
            await repo.verifyPurchase(gymId: gymId, purchase: purchase);
          } catch (_) {
            verifyErrorMessage =
                'Satın alma doğrulanamadı, tekrar dene ya da destek ile iletişime geç.';
          }
        }
        await repo.completePurchase(purchase);
        _isPurchasing = false;
        _pendingProductId = null;
        state = state.copyWith(
          isPurchasing: false,
          pendingProductId: null,
          purchaseErrorMessage: verifyErrorMessage,
        );
      } else if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        await repo.completePurchase(purchase);
        _isPurchasing = false;
        _pendingProductId = null;
        state = state.copyWith(
          isPurchasing: false,
          pendingProductId: null,
          purchaseErrorMessage: purchase.status == PurchaseStatus.error
              ? 'Satın alma tamamlanamadı, mağaza bağlantısını kontrol edip tekrar dene.'
              : null,
        );
      }
    }
  }
}
