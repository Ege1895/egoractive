import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'package:egoractive/modules/subscription/service/subscription_purchase_service.dart';

PricingPhaseWrapper _phase(int micros, String period, String price) =>
    PricingPhaseWrapper(
      billingCycleCount: micros == 0 ? 1 : 0,
      billingPeriod: period,
      formattedPrice: price,
      priceAmountMicros: micros,
      priceCurrencyCode: 'TRY',
      recurrenceMode: micros == 0
          ? RecurrenceMode.finiteRecurring
          : RecurrenceMode.infiniteRecurring,
    );

/// Play'in bir abonelik için döndürdüğü kayıtlar: base plan + varsa
/// ücretsiz deneme teklifi (eklenti her teklif için ayrı kayıt üretir).
List<GooglePlayProductDetails> _monthly({required bool withTrial}) {
  const recurring = '₺1.249,99';
  return GooglePlayProductDetails.fromProductDetails(
    ProductDetailsWrapper(
      description: 'desc',
      name: 'Monthly',
      productId: 'egoractive_business_monthly',
      productType: ProductType.subs,
      title: 'Egoractive Aylık',
      subscriptionOfferDetails: [
        SubscriptionOfferDetailsWrapper(
          basePlanId: 'monthly',
          offerTags: const [],
          offerIdToken: 'base-token',
          pricingPhases: [_phase(1249990000, 'P1M', recurring)],
        ),
        if (withTrial)
          SubscriptionOfferDetailsWrapper(
            basePlanId: 'monthly',
            offerId: 'free-trial-14d',
            offerTags: const [],
            offerIdToken: 'trial-token',
            pricingPhases: [
              _phase(0, 'P14D', 'Ücretsiz'),
              _phase(1249990000, 'P1M', recurring),
            ],
          ),
      ],
    ),
  );
}

void main() {
  test('deneme teklifi varsa her abonelik için tek kayıt ve deneme teklifi seçilir', () {
    final all = _monthly(withTrial: true);
    expect(all, hasLength(2), reason: 'eklenti teklif başına ayrı kayıt üretir');

    final selected = selectSubscriptionOffers(all);
    expect(selected, hasLength(1));
    expect((selected.single as GooglePlayProductDetails).offerToken, 'trial-token');

    final product = toSubscriptionProduct(selected.single);
    expect(product.price, '₺1.249,99', reason: 'kartta "Ücretsiz" değil yenilenme fiyatı');
    expect(product.trialDays, 14);
  });

  test('deneme teklifi yoksa (uygun değil) base plan seçilir, deneme gösterilmez', () {
    final selected = selectSubscriptionOffers(_monthly(withTrial: false));
    expect(selected, hasLength(1));
    expect((selected.single as GooglePlayProductDetails).offerToken, 'base-token');

    final product = toSubscriptionProduct(selected.single);
    expect(product.price, '₺1.249,99');
    expect(product.trialDays, isNull);
  });
}
