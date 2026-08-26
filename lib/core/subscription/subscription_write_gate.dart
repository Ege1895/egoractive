import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/subscription/controller/subscription_controller.dart';
import '../../modules/subscription/domain/subscription_state.dart';
import '../../modules/subscription/ui/panels/subscription_panel.dart';
import '../constants/app_spacing.dart';
import '../panels/panel_stack_controller.dart';
import '../router/app_router.dart';
import '../theme/app_theme.dart';

/// F6-3 — yeni içerik oluşturan (üye, paket satışı, seans, grup dersi,
/// etkinlik, gider, paket kataloğu) her ekran, yazma işlemine başlamadan
/// önce bunu çağırır. Salonun aboneliği `trial`/`active` değilse (deneme
/// süresi dolmuş ya da abonelik sona ermiş) engelleyici bir uyarı gösterir
/// ve `false` döner — çağıran taraf yazmayı hiç denemez. `firestore.rules`
/// içindeki `gymSubscriptionAllowsWrite()` bunun gerçek güvenlik sınırı;
/// bu fonksiyon sadece kullanıcıya erken, net bir geri bildirim verir.
///
/// Aboneliği yenileme sorumluluğu SADECE admin'e ait — antrenör/üye
/// hesapları bu uyarıyı hiç görmemeli (onlar zaten kendi admin'lerinin
/// aboneliğine bağlı çalışıyor, aboneliği yenilemek onların elinde değil).
/// Bu yüzden rol admin değilse kontrol hiç yapılmadan geçiliyor.
Future<bool> ensureSubscriptionAllowsWrite(BuildContext context, WidgetRef ref) async {
  final role = ref.read(currentRoleProvider).valueOrNull;
  if (role != AppRole.admin) return true;

  final subscription = ref.read(subscriptionControllerProvider);
  final status = subscription.status;
  if (subscription.subscriptionExempt ||
      status == SubscriptionStatus.trial ||
      status == SubscriptionStatus.active) {
    return true;
  }
  if (!context.mounted) return false;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final colors = dialogContext.appColors;
      final typography = dialogContext.appTypography;

      return AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
        title: Text('Aboneliğini yenile', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 17)),
        content: Text(
          status == SubscriptionStatus.expired
              ? 'Deneme sürenin süresi doldu. Bu işlemi yapabilmek için aboneliğini yenilemen gerekiyor.'
              : 'Bu işlemi yapabilmek için aktif bir aboneliğin olması gerekiyor.',
          style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Vazgeç', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Bu diyalog çoğunlukla bir bottom sheet'in (ör. "Yeni seans")
              // İÇİNDEN açılıyor — diyalog kapanınca sheet'in kendisi hâlâ
              // açık kalıyordu, abonelik paneli onun ARKASINDA açılmış gibi
              // görünüyordu. `context` (dialogContext değil, orijinal çağıran
              // context) sheet'e aitse `canPop()` true döner, o zaman önce
              // sheet kapatılıyor. Sheet olmayan (doğrudan panel içi) çağrı
              // noktalarında zaten pop edilecek bir şey yok, no-op kalıyor.
              if (context.mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              ref.read(panelStackControllerProvider.notifier).push(const SubscriptionPanel());
            },
            child: Text('Aboneliğe git', style: typography.bodyMedium.copyWith(color: colors.primary)),
          ),
        ],
      );
    },
  );
  return false;
}
