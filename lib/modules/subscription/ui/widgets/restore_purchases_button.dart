import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/subscription_controller.dart';

/// "Satın alımları geri yükle" — mağazadaki (StoreKit / Play) aktif
/// aboneliği yeniden çekip sunucuda doğrulatır (bkz.
/// `SubscriptionController.restorePurchases`). Apple 3.1.1, satın alma
/// sunulan her ekranda bir geri yükleme yolu bekliyor; özellikle atlanamayan
/// zorunlu abonelik ekranında, ödeme yapıp doğrulaması yarıda kalan
/// kullanıcının tek çıkış yolu bu.
///
/// Ekranda yer çok kısıtlı olduğu için: çerçevesiz, ikon + kısa metin,
/// soluk renk (birincil "başlat" butonuyla yarışmaz). Sonuç mesajı yalnızca
/// varsa ve yumuşak bir geçişle açılır; normalde hiç yer kaplamaz.
class RestorePurchasesButton extends ConsumerWidget {
  const RestorePurchasesButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final subscription = ref.watch(subscriptionControllerProvider);
    final restoring = subscription.isRestoring;
    final enabled = !restoring && !subscription.isPurchasing;
    final message = subscription.restoreMessage;
    final foreground = enabled
        ? colors.onSurfaceVariant
        : colors.onSurfaceMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: enabled
              ? () => ref
                    .read(subscriptionControllerProvider.notifier)
                    .restorePurchases()
              : null,
          style: TextButton.styleFrom(
            // Görsel olarak ince, ama dokunma alanı Apple'ın önerdiği
            // 44 pt'nin altına düşmesin.
            minimumSize: const Size(0, AppSpacing.minTouchTarget),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            foregroundColor: foreground,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 16,
                child: restoring
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(foreground),
                      )
                    : Icon(Icons.restore_rounded, size: 16, color: foreground),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                ref.watch(
                  rcTextProvider(
                    restoring
                        ? RemoteConfigKeys.subscriptionRestoreInProgress
                        : RemoteConfigKeys.subscriptionRestoreButton,
                  ),
                ),
                style: typography.bodyMedium.copyWith(
                  color: foreground,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
