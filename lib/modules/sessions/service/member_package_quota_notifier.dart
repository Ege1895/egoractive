import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../domain/member_package_alert.dart';

part 'member_package_quota_notifier.g.dart';

/// Bir seans tamamlandığında üyenin kalan ders toplamı "bitiyor"/"bitti"
/// eşiğini yeni geçtiyse `notifyMemberPackageQuota` callable'ını çağırıp
/// üyeye push attırır. Eşik hesaplaması burada (client'ta) yapılıyor —
/// önceki sürüm bunun için `users/{uid}` üzerindeki HER yazımda tetiklenen
/// bir Firestore trigger kullanıyordu; bu, isim/telefon değişikliği gibi
/// ilgisiz yazımlarda bile gereksiz invocation/Firestore okuma maliyeti
/// demekti. Artık fonksiyon SADECE gerçek bir eşik geçişinde çağrılıyor.
class MemberPackageQuotaNotifier {
  const MemberPackageQuotaNotifier(this._remoteConfig);

  final RemoteConfigService _remoteConfig;

  /// Push bildirimi ikincil bir etki — çağrısı başarısız olursa (ağ hatası,
  /// fonksiyon hatası vb.) sessizce yutulur, seans tamamlama akışını asla
  /// bozmaz.
  Future<void> maybeNotify({
    required String memberId,
    required int beforeTotal,
    required int afterTotal,
  }) async {
    final alert = resolveMemberPackageAlert(
      beforeTotal: beforeTotal,
      afterTotal: afterTotal,
      endingSoonThreshold: _remoteConfig.memberEndingSoonSessionsThreshold,
    );
    if (alert == null) return;

    try {
      await FirebaseFunctions.instance
          .httpsCallable('notifyMemberPackageQuota')
          .call<Map<String, dynamic>>({
            'memberId': memberId,
            'alert': alert == MemberPackageAlert.endingSoon
                ? 'endingSoon'
                : 'none',
            'totalRemaining': afterTotal < 0 ? 0 : afterTotal,
          });
    } catch (_) {
      // Sessizce yutulur — yukarıdaki doc yorumuna bkz.
    }
  }
}

@riverpod
MemberPackageQuotaNotifier memberPackageQuotaNotifier(
  MemberPackageQuotaNotifierRef ref,
) => MemberPackageQuotaNotifier(ref.watch(remoteConfigServiceProvider));
