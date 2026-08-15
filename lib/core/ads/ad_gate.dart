import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../modules/subscription/controller/subscription_controller.dart';
import '../../modules/subscription/domain/subscription_state.dart';
import '../remote_config/remote_config_service.dart';

part 'ad_gate.g.dart';

/// F6-2 — bir üyeye banner reklam gösterilip gösterilmeyeceğine karar
/// verir: salonun aboneliği `active` DEĞİLSE VE `cfg_free_version_ads_enabled`
/// RC flag'i açıksa reklam gösterilir. Flag kapatılırsa hiç kimseye
/// (abone olsun olmasın) reklam gösterilmez — global kill-switch.
@riverpod
bool shouldShowAds(ShouldShowAdsRef ref) {
  // RC henüz hazır olmadığı (ör. Firebase başlatılmamış test ortamı)
  // durumlarda widget'ı çökertmemek için burada savunmacı: hata olursa
  // reklam gösterilmez (bkz. FeatureFlags._flag ile aynı gerekçe).
  final bool adsGloballyEnabled;
  try {
    adsGloballyEnabled = ref.watch(remoteConfigServiceProvider).freeVersionAdsEnabled;
  } on Exception {
    return false;
  }
  if (!adsGloballyEnabled) return false;

  final subscription = ref.watch(subscriptionControllerProvider);
  return subscription.status != SubscriptionStatus.active;
}
