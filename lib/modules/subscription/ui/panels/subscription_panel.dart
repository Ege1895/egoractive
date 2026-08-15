import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/subscription_controller.dart';
import '../../domain/subscription_state.dart';

/// F6-1 — Admin · Ayarlar > Abonelik. Aktif durumu (trial/active/expired)
/// gösterir, mağaza ürünlerini listeler ve satın alma akışını başlatır.
/// Satın alma tamamlanınca gerçek durum güncellemesi `verifySubscriptionPurchase`
/// callable'ı üzerinden gelir (bu ekran doğrudan Firestore'a yazmaz).
class SubscriptionPanel extends BasePanel {
  const SubscriptionPanel({super.key});

  @override
  ConsumerState<SubscriptionPanel> createState() => _SubscriptionPanelState();
}

class _SubscriptionPanelState extends BasePanelState<SubscriptionPanel> {
  Future<List<SubscriptionProduct>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ref.read(subscriptionControllerProvider.notifier).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final subscription = ref.watch(subscriptionControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Abonelik', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  _StatusCard(subscription: subscription),
                  const SizedBox(height: AppSpacing.lg),
                  FutureBuilder<List<SubscriptionProduct>>(
                    future: _productsFuture,
                    builder: (context, snapshot) {
                      final products = snapshot.data ?? const [];
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(padding: EdgeInsets.all(AppSpacing.lg), child: CircularProgressIndicator()));
                      }
                      if (products.isEmpty) {
                        return Text('Şu an satın alınabilir bir abonelik ürünü bulunamadı.', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted));
                      }
                      return Column(
                        children: [
                          for (final product in products) ...[
                            _ProductCard(
                              product: product,
                              isBusy: subscription.isPurchasing,
                              onTap: () => ref.read(subscriptionControllerProvider.notifier).purchase(product.id),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.subscription});

  final SubscriptionState subscription;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_statusLabel(subscription.status), style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
          if (subscription.status == SubscriptionStatus.trial && subscription.trialEndsAt != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(_trialLabel(subscription.trialEndsAt!), style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  String _statusLabel(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.trial:
        return 'Deneme sürümü';
      case SubscriptionStatus.active:
        return 'Abonelik aktif';
      case SubscriptionStatus.expired:
        return 'Abonelik süresi doldu';
      case SubscriptionStatus.none:
        return 'Abonelik yok';
    }
  }

  String _trialLabel(DateTime trialEndsAt) {
    final remaining = trialEndsAt.difference(DateTime.now()).inDays;
    if (remaining <= 0) return 'Deneme süresi bugün doluyor.';
    return 'Deneme süresi $remaining gün sonra doluyor.';
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.isBusy, required this.onTap});

  final SubscriptionProduct product;
  final bool isBusy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
                const SizedBox(height: AppSpacing.xs),
                Text(product.price, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          FilledButton(
            onPressed: isBusy ? null : onTap,
            child: Text(isBusy ? 'İşleniyor…' : 'Satın al'),
          ),
        ],
      ),
    );
  }
}
