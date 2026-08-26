import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'subscription_verification_service.g.dart';

/// F6-1d — satın alma tamamlandığında `verifySubscriptionPurchase`
/// callable'ını çağırır. Bu fonksiyon Apple/Google'ın sunucu API'lerine
/// karşı makbuzu doğrulayıp `gyms/{gymId}.subscriptionStatus`'u Admin SDK
/// ile günceller (client bu alanları doğrudan yazamaz, bkz. firestore.rules).
class SubscriptionVerificationService {
  const SubscriptionVerificationService();

  Future<void> verifyPurchase({required String gymId, required PurchaseDetails purchase}) {
    final callable = FirebaseFunctions.instance.httpsCallable('verifySubscriptionPurchase');
    return callable.call<void>({
      'gymId': gymId,
      'productId': purchase.productID,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'verificationData': purchase.verificationData.serverVerificationData,
    });
  }

  /// GEÇİCİ — mağaza ürünleri henüz canlı değilken (bkz.
  /// `SubscriptionPurchaseService.lastFetchWasMock`) gerçek satın alma
  /// yerine bunu çağırır — `startMockSubscription` callable'ı gerçek bir
  /// doğrulama yapmadan salonu `trial`a geçirir.
  Future<void> startMockSubscription({required String gymId, required String productId}) {
    final callable = FirebaseFunctions.instance.httpsCallable('startMockSubscription');
    return callable.call<void>({'gymId': gymId, 'productId': productId});
  }
}

@riverpod
SubscriptionVerificationService subscriptionVerificationService(SubscriptionVerificationServiceRef ref) {
  return const SubscriptionVerificationService();
}
