import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/ad_constants.dart';

part 'ad_consent_service.g.dart';

/// F6-2 — Google'ın "User Messaging Platform" (UMP) SDK'sı ile GDPR/UK
/// rıza akışı. AB/İngiltere'deki kullanıcılara reklam göstermeden önce bu
/// akışın tamamlanmış olması Google'ın reklam politikası gereği ZORUNLU.
/// AB/İngiltere dışındaki kullanıcılar için [ConsentInformation] formun
/// gerekmediğine kendi karar verir — o durumda hiçbir UI gösterilmez,
/// `ensureConsent()` anında `true` döner.
class AdConsentService {
  const AdConsentService();

  /// Rıza bilgisini günceller, gerekiyorsa formu gösterip kapanmasını
  /// bekler, sonunda reklam isteği yapılıp yapılamayacağını döner.
  Future<bool> ensureConsent() async {
    final completer = Completer<bool>();
    final params = ConsentRequestParameters(
      consentDebugSettings: debugTestDeviceIds.isEmpty
          ? null
          : ConsentDebugSettings(testIdentifiers: debugTestDeviceIds),
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        completer.complete(await ConsentInformation.instance.canRequestAds());
      },
      (_) => completer.complete(false),
    );

    return completer.future;
  }
}

@riverpod
AdConsentService adConsentService(AdConsentServiceRef ref) => const AdConsentService();
