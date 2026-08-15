import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'ad_consent_service.dart';
import 'ad_gate.dart';
import 'home_return_signal.dart';

const _firstInterstitialDelay = Duration(seconds: 30);
const _minIntervalBetweenAds = Duration(minutes: 3);

/// F6-2 — otomatik geçiş reklamı (interstitial). AdMob politikası, reklamın
/// rastgele bir zamanlayıcıyla değil kullanıcının kendi başlattığı doğal bir
/// geçiş anında gösterilmesini şart koşuyor. Bu yüzden:
///
/// - İlk reklam üye shell'i açıldıktan 30 saniye sonra (tek seferlik, henüz
///   navigasyon olmadığı için burada zamanlayıcı kullanmak zorundayız).
/// - Sonraki reklamlar SADECE kullanıcı "Ana Sayfa"ya döndüğünde
///   ([HomeReturnSignal] — sekmeye dokunma ya da geri navigasyonuyla shell'e
///   dönme) VE son reklamın üzerinden en az [_minIntervalBetweenAds]
///   geçmişse gösterilir. Reklam gösterildikten sonra sayaç sıfırlanır.
///
/// Görünmez bir widget — hiçbir UI çizmez. Görünürlüğü banner ile aynı
/// kapıdan geçer ([shouldShowAdsProvider] + [AdConsentService]).
class AdInterstitialGate extends ConsumerStatefulWidget {
  const AdInterstitialGate({super.key});

  @override
  ConsumerState<AdInterstitialGate> createState() => _AdInterstitialGateState();
}

class _AdInterstitialGateState extends ConsumerState<AdInterstitialGate> {
  Timer? _firstAdTimer;
  bool _isShowing = false;
  late DateTime _lastAdAt;

  @override
  void initState() {
    super.initState();
    _lastAdAt = DateTime.now();
    _firstAdTimer = Timer(_firstInterstitialDelay, _showAndResetCooldown);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(homeReturnSignalProvider, (previous, next) {
      if (DateTime.now().difference(_lastAdAt) >= _minIntervalBetweenAds) {
        _showAndResetCooldown();
      }
    });
    return const SizedBox.shrink();
  }

  Future<void> _showAndResetCooldown() async {
    final shown = await _maybeShow();
    if (shown) _lastAdAt = DateTime.now();
  }

  Future<bool> _maybeShow() async {
    if (_isShowing || !ref.read(shouldShowAdsProvider)) return false;

    final canRequestAds = await ref.read(adConsentServiceProvider).ensureConsent();
    if (!mounted || !canRequestAds || !ref.read(shouldShowAdsProvider)) return false;

    _isShowing = true;
    final completer = Completer<bool>();
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (dismissedAd) {
              dismissedAd.dispose();
              _isShowing = false;
            },
            onAdFailedToShowFullScreenContent: (failedAd, _) {
              failedAd.dispose();
              _isShowing = false;
            },
          );
          ad.show();
          completer.complete(true);
        },
        onAdFailedToLoad: (_) {
          _isShowing = false;
          completer.complete(false);
        },
      ),
    );
    return completer.future;
  }

  @override
  void dispose() {
    _firstAdTimer?.cancel();
    super.dispose();
  }
}
