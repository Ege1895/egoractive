import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/subscription_state.dart';
import '../repository/subscription_repository.dart';
import '../../../core/remote_config/remote_config_service.dart';

part 'subscription_controller.g.dart';

/// Salon Abonelik ve Erişim Akışı — `app_access.dart`'taki merkezi erişim
/// kapısı da bunu izler; ikisi AYRI birer `watchState()` çağrısı (dolayısıyla
/// ayrı birer Firestore listener'ı) açmak yerine bu TEK provider'ı paylaşır
/// (Riverpod aynı provider'ı izleyen tüm taraflar için tek bir alttaki
/// stream'i yeniden kullanır) — aksi halde admin oturumlarında aynı
/// `gyms/{gymId}` dokümanı için (biri bu controller'dan, biri erişim
/// kapısından) iki ayrı canlı dinleyici açık kalırdı.
@riverpod
Stream<SubscriptionState> subscriptionStateForGym(
  SubscriptionStateForGymRef ref,
  String gymId,
) {
  return ref.watch(subscriptionRepositoryProvider).watchState(gymId);
}

/// Geri yükleme isteğinden sonra mağazadan olay beklenecek süre — hiç satın
/// alım yoksa `purchaseStream`'e hiçbir şey düşmediği için tek bitiş sinyali
/// bu.
const _restoreTimeoutDuration = Duration(seconds: 10);

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

  // F13-1 — geri yükleme durumu da aynı gerekçeyle örnek alanında tutuluyor:
  // Firestore'dan gelen her snapshot build()'i tekrar çalıştırıp state'i
  // sıfırdan üretiyor, bu alanlar `gyms/{gymId}` dokümanının parçası değil.
  bool _isRestoring = false;
  String? _restoreMessage;
  bool _sawRestoredPurchase = false;
  Timer? _restoreTimeout;

  @override
  SubscriptionState build() {
    ref.onDispose(() {
      _purchaseSub?.cancel();
      _restoreTimeout?.cancel();
    });
    _purchaseSub ??= ref
        .watch(subscriptionRepositoryProvider)
        .purchaseUpdates
        .listen(_onPurchaseUpdate);

    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    final base = gymId == null
        ? const SubscriptionState()
        : ref.watch(subscriptionStateForGymProvider(gymId)).valueOrNull ??
              const SubscriptionState();
    return base.copyWith(
      isPurchasing: _isPurchasing,
      pendingProductId: _pendingProductId,
      isRestoring: _isRestoring,
      restoreMessage: _restoreMessage,
    );
  }

  Future<List<SubscriptionProduct>> fetchProducts() => ref
      .read(subscriptionRepositoryProvider)
      .fetchProducts(locale: ref.read(localeControllerProvider));

  /// Bkz. `SubscriptionPurchaseService.lastFetchWasMock` — `fetchProducts()`
  /// tamamlanana kadar `false`.
  bool get lastFetchWasMock =>
      ref.read(subscriptionRepositoryProvider).lastFetchWasMock;

  /// GEÇİCİ — mağaza ürünleri henüz canlı değilken [purchase] yerine bunu
  /// çağırır (bkz. `startMockSubscription` callable'ındaki yorum). Gerçek
  /// bir mağaza işlemi olmadığı için `_onPurchaseUpdate` akışından
  /// geçmiyor — başarı/hata burada doğrudan ele alınıyor.
  Future<void> startMockSubscription(String productId) async {
    if (_isPurchasing) return;
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    _isPurchasing = true;
    _pendingProductId = productId;
    state = state.copyWith(
      isPurchasing: true,
      pendingProductId: productId,
      purchaseErrorMessage: null,
    );
    try {
      await ref
          .read(subscriptionRepositoryProvider)
          .startMockSubscription(gymId: gymId, productId: productId);
      _isPurchasing = false;
      _pendingProductId = null;
      state = state.copyWith(isPurchasing: false, pendingProductId: null);
    } catch (_) {
      _isPurchasing = false;
      _pendingProductId = null;
      state = state.copyWith(
        isPurchasing: false,
        pendingProductId: null,
        purchaseErrorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.subscriptionStartError),
        ),
      );
    }
  }

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

    // F13-7 — Android'de aktif bir aboneliği olan salon BAŞKA bir plana
    // geçiyorsa (aylık → yıllık), eski satın alma Play'e devredilmeli.
    // Devredilmezse Play bunu bir değişiklik değil YENİ bir abonelik sayar
    // ve salon iki kez ücretlendirilir — üstelik uygulama içinde her şey
    // doğru görünür, çift ödeme yalnızca Play makbuzunda fark edilir.
    //
    // `_isPurchasing` bilerek bu adımdan SONRA kuruluyor: aşağıdaki
    // `restorePurchases` çağrısı `_onPurchaseUpdate`'i tetikleyip satın alma
    // durumunu sıfırlayabilirdi.
    final replacing = await _resolvePurchaseToReplace(productId);

    _isPurchasing = true;
    _pendingProductId = productId;
    state = state.copyWith(
      isPurchasing: true,
      pendingProductId: productId,
      purchaseErrorMessage: null,
    );
    try {
      // `buySubscription` iOS'ta artık gerçek StoreKit2 sonucunu dönüyor
      // (bkz. `SubscriptionPurchaseService.buySubscription`) — `true`,
      // kullanıcının mağaza sayfasını iptal ettiği anlamına gelir. StoreKit2
      // iptalde hiçbir Transaction oluşturmadığından bu durumda
      // `purchaseStream`'e hiç olay düşmeyecektir; o yüzden burada hemen
      // sessizce sıfırlıyoruz (tıpkı `_onPurchaseUpdate`'teki
      // `PurchaseStatus.canceled` dalı gibi — kullanıcının kendi kararı,
      // hata mesajı gösterilmiyor). Android'de (ve StoreKit1 fallback'inde)
      // her zaman `false` döner, sonuç her zamanki gibi `purchaseStream`
      // üzerinden `_onPurchaseUpdate`'e gelir.
      final userCanceled = await ref
          .read(subscriptionRepositoryProvider)
          .buySubscription(productId, replacing: replacing);
      if (userCanceled && _isPurchasing && _pendingProductId == productId) {
        _isPurchasing = false;
        _pendingProductId = null;
        state = state.copyWith(isPurchasing: false, pendingProductId: null);
      }
    } catch (_) {
      _isPurchasing = false;
      _pendingProductId = null;
      state = state.copyWith(
        isPurchasing: false,
        pendingProductId: null,
        purchaseErrorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.subscriptionPurchaseStartError),
        ),
      );
    }
  }

  /// Yükseltmede devredilecek eski aboneliği bulur; yoksa `null` döner.
  ///
  /// Önbellek yalnızca bu oturumda görülen satın almaları taşıdığı için
  /// (uygulama yeniden açıldığında boştur) gerekirse `restorePurchases`
  /// çağrılıp mağazanın mevcut aboneliği akışa düşürmesi bekleniyor. Bu
  /// bekleme sınırlı: token gelmezse yükseltme ENGELLENMİYOR, düz satın
  /// alma olarak sürüyor — kullanıcıyı "yükseltemiyorum" diye kilitlemek,
  /// nadir bir çift abonelik riskinden daha kötü bir sonuç olurdu.
  Future<GooglePlayPurchaseDetails?> _resolvePurchaseToReplace(
    String productId,
  ) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    // Aktif abonelik yoksa devredilecek bir şey de yok.
    if (state.status != SubscriptionStatus.active) return null;
    if (state.productId == productId) return null;

    final cached = repo.androidPurchaseToReplace(productId);
    if (cached != null) return cached;

    try {
      await repo.restorePurchases();
    } catch (_) {
      return null;
    }

    for (var i = 0; i < 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final found = repo.androidPurchaseToReplace(productId);
      if (found != null) return found;
    }
    return null;
  }

  /// F13-1 — Apple Guideline 3.1.1: mağazadaki satın alımı yeniden
  /// keşfetme yolu. Bu uygulamada yetkilendirme sunucuda durduğu için
  /// (`gyms/{gymId}.subscriptionStatus`) çoğu "yeni cihaz" senaryosunda
  /// zaten gerek kalmıyor — ama şu durumlarda TEK kurtarma yolu bu:
  ///
  /// * `verifyPurchase` hata verse bile işlem [_onPurchaseUpdate]'te her
  ///   zaman `completePurchase` ile kapatılıyor (kullanıcı "mağaza
  ///   bekleniyor" ekranında kilitli kalmasın diye). Bedeli: işlem mağaza
  ///   kuyruğundan düşüyor ve bir daha kendiliğinden sunulmuyor. Ağ
  ///   koptuğu bir anda ödeme alınmış ama salon pasif kalmış olabilir.
  /// * Ertelenmiş işlemler (Ask to Buy, banka doğrulaması) uygulama kapalıyken
  ///   tamamlanırsa olay kaçar.
  /// * `resetGymSubscription` sonrası mağazadaki abonelik ile salon
  ///   dokümanının yeniden bağlanması gerekir.
  ///
  /// Sonuç mağazadan bu çağrının dönüşüyle DEĞİL, `purchaseStream`'e düşen
  /// `restored` olaylarıyla geliyor; hiç satın alım yoksa stream'e hiçbir
  /// şey düşmüyor. Bu yüzden bir zaman aşımı var: onsuz "satın alımı
  /// olmayan kullanıcı" sonsuza kadar yükleniyor durumunda kalırdı.
  Future<void> restorePurchases() async {
    if (_isRestoring) return;
    _isRestoring = true;
    _sawRestoredPurchase = false;
    _restoreMessage = null;
    state = state.copyWith(
      isRestoring: true,
      restoreMessage: null,
      purchaseErrorMessage: null,
    );

    try {
      await ref.read(subscriptionRepositoryProvider).restorePurchases();
    } catch (_) {
      _finishRestore(RemoteConfigKeys.subscriptionRestoreError);
      return;
    }

    _restoreTimeout?.cancel();
    _restoreTimeout = Timer(_restoreTimeoutDuration, () {
      if (!_isRestoring) return;
      _finishRestore(
        _sawRestoredPurchase
            ? RemoteConfigKeys.subscriptionRestoreSuccess
            : RemoteConfigKeys.subscriptionRestoreEmpty,
      );
    });
  }

  void _finishRestore(String messageKey) {
    _restoreTimeout?.cancel();
    _isRestoring = false;
    _restoreMessage = ref.read(rcTextProvider(messageKey));
    state = state.copyWith(isRestoring: false, restoreMessage: _restoreMessage);
  }

  /// Kullanıcı mesajını temizler (ör. bilgi satırı kapatıldığında).
  void clearRestoreMessage() {
    _restoreMessage = null;
    state = state.copyWith(restoreMessage: null);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    final repo = ref.read(subscriptionRepositoryProvider);
    final gymId = ref.read(activeGymIdProvider).valueOrNull;

    for (final purchase in purchases) {
      // F13-7 — yükseltmede devredilecek eski aboneliğin token'ı yalnızca
      // bu akıştan elde edilebiliyor, o yüzden her satın alma önbelleğe
      // alınıyor (doğrulamadan ÖNCE: doğrulama hata verse bile token'ı
      // bilmemiz gerekiyor).
      repo.rememberPurchase(purchase);

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.status == PurchaseStatus.restored) {
          _sawRestoredPurchase = true;
        }
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
          } catch (e) {
            // Aynı Apple/Google hesabıyla önceden BAŞKA bir salon abone
            // olunmuşsa mağaza (kullanıcıdan tekrar ödeme almadan) o aktif
            // aboneliğin makbuzunu geri veriyor — backend bunu ayrı bir
            // hata koduyla reddediyor (bkz. apply-subscription-update.ts),
            // "tekrar dene" burada işe yaramaz, kullanıcının anlaması için
            // ayrı, net bir mesaj gerekiyor.
            verifyErrorMessage =
                e is FirebaseFunctionsException && e.code == 'already-exists'
                ? ref.read(
                    rcTextProvider(
                      RemoteConfigKeys.subscriptionAccountAlreadyUsedError,
                    ),
                  )
                : ref.read(
                    rcTextProvider(
                      RemoteConfigKeys.subscriptionVerificationError,
                    ),
                  );
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
              ? ref.read(
                  rcTextProvider(
                    RemoteConfigKeys.subscriptionPurchaseCompleteError,
                  ),
                )
              : null,
        );
      }
    }
  }
}
