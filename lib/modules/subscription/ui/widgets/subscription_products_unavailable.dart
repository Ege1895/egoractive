import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';

/// Mağazadan abonelik planları alınamadığında (bağlantı hatası, ürün
/// yapılandırması eksik vb.) abonelik ekranlarında planların yerine
/// gösterilir. Sahte plan göstermek yerine durumu açıkça söyler ve
/// kullanıcıya yeniden deneme imkânı verir.
class SubscriptionProductsUnavailable extends ConsumerWidget {
  const SubscriptionProductsUnavailable({required this.onRetry, super.key});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenEdge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: colors.onSurfaceMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.subscriptionProductsUnavailableTitle,
                ),
              ),
              textAlign: TextAlign.center,
              style: typography.headingSmall.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              ref.watch(
                rcTextProvider(
                  RemoteConfigKeys.subscriptionProductsUnavailableBody,
                ),
              ),
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: ref.watch(
                rcTextProvider(RemoteConfigKeys.subscriptionProductsRetry),
              ),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
