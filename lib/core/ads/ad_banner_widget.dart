import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_constants.dart';
import 'ad_consent_service.dart';
import 'ad_gate.dart';

/// F6-2 — `AppTabShell`'in alt tab bar'ının hemen üstüne yerleştirilen
/// banner reklam. Görünürlüğü tamamen [shouldShowAdsProvider]'a bağlı:
/// abone olan bir salonun üyesinde ya da `cfg_free_version_ads_enabled`
/// kapalıyken hiç yer kaplamaz (SizedBox.shrink). Reklam isteğinden önce
/// [AdConsentService] ile GDPR/UK rıza akışı tamamlanır — AB/İngiltere
/// dışındaki kullanıcılarda bu adım anında geçer, UI göstermez.
class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (ref.read(shouldShowAdsProvider)) {
      _maybeLoadAd();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shouldShowAdsProvider, (previous, shouldShow) {
      if (shouldShow && _bannerAd == null) {
        _maybeLoadAd();
      } else if (!shouldShow) {
        _disposeAd();
      }
    });

    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  Future<void> _maybeLoadAd() async {
    final canRequestAds = await ref.read(adConsentServiceProvider).ensureConsent();
    if (!mounted || !canRequestAds || !ref.read(shouldShowAdsProvider)) return;
    _loadAd();
  }

  void _loadAd() {
    final ad = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _isLoaded = false);
          _bannerAd = null;
        },
      ),
    );
    _bannerAd = ad;
    ad.load();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    if (mounted) setState(() => _isLoaded = false);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
