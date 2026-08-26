import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../controller/subscription_controller.dart';
import '../../domain/subscription_state.dart';

/// F6-1e — Yeni salon oluşturan admin'in girişten hemen sonra gördüğü,
/// atlanamayan abonelik başlatma ekranı. `app_access.dart`/`main.dart`'ın
/// merkezi erişim kapısı admin'in salonu abone değilse (bkz.
/// `RemoteConfigKeys.requireSubscriptionOnboarding`) bunu `AdminShellPanel`
/// yerine kök olarak açar — bu yüzden burada geri butonu YOK ve sistem geri
/// tuşu da yutulur ([onBackRequested]); tek çıkış yolu bir paket seçip
/// mağazanın kendi "free trial" introductory offer'ıyla gerçekten abone
/// olmak. Satın alma doğrulanıp `subscriptionStatus` `active`/`trial`
/// olduğu anda aynı merkezi kapı (`appAccessProvider`, canlı Firestore
/// akışını izliyor) kendiliğinden `AdminShellPanel`'e geçer — bu panelin
/// kendi başına bir yönlendirme yapmasına gerek yok.
class SubscriptionOnboardingPanel extends BasePanel {
  const SubscriptionOnboardingPanel({super.key});

  @override
  ConsumerState<SubscriptionOnboardingPanel> createState() =>
      _SubscriptionOnboardingPanelState();
}

class _SubscriptionOnboardingPanelState
    extends BasePanelState<SubscriptionOnboardingPanel> {
  Future<List<SubscriptionProduct>>? _productsFuture;
  String? _selectedProductId;

  static String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';

  @override
  void initState() {
    super.initState();
    _productsFuture = ref
        .read(subscriptionControllerProvider.notifier)
        .fetchProducts();
  }

  @override
  bool onBackRequested() => true;

  bool _isYearly(String productId) =>
      productId == gymYearlySubscriptionProductId;

  void _ensureSelection(List<SubscriptionProduct> products) {
    if (_selectedProductId != null &&
        products.any((p) => p.id == _selectedProductId)) {
      return;
    }
    final yearly = products.where((p) => _isYearly(p.id)).firstOrNull;
    _selectedProductId =
        yearly?.id ?? (products.isEmpty ? null : products.first.id);
  }

  String _fill(String template, Map<String, String> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final locale = ref.watch(localeControllerProvider);
    final rc = ref.watch(remoteConfigServiceProvider);
    final subscription = ref.watch(subscriptionControllerProvider);
    final days = '${rc.trialDurationDays}';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.xxl,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rc.getText(
                        RemoteConfigKeys.subscriptionOnboardingTitle,
                        locale,
                      ),
                      style: typography.headingLarge.copyWith(
                        color: colors.onSurface,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subscription.trialUsed
                          ? _fill(
                              rc.getText(
                                RemoteConfigKeys
                                    .subscriptionOnboardingSubtitlePaidOnly,
                                locale,
                              ),
                              {'store': _storeName},
                            )
                          : _fill(
                              rc.getText(
                                RemoteConfigKeys.subscriptionOnboardingSubtitle,
                                locale,
                              ),
                              {'days': days, 'store': _storeName},
                            ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<SubscriptionProduct>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: AppLoadingIndicator());
                    }
                    final products = snapshot.data ?? const [];
                    _ensureSelection(products);
                    return _buildBody(
                      context,
                      products,
                      subscription,
                      rc,
                      locale,
                      days,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
    String locale,
    String days,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final selected = products
        .where((p) => p.id == _selectedProductId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.lg,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
      children: [
        if (products.isEmpty)
          Text(
            rc.getText(
              RemoteConfigKeys.subscriptionOnboardingNoProducts,
              locale,
            ),
            style: typography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
            ),
          )
        else
          for (final product in products)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _OnboardingPlanCard(
                product: product,
                selected: product.id == _selectedProductId,
                busy: subscription.isPurchasing,
                badge: _isYearly(product.id)
                    ? rc.getText(RemoteConfigKeys.subscriptionYearlyBadge, locale)
                    : null,
                subLabel: _isYearly(product.id)
                    ? rc.getText(RemoteConfigKeys.subscriptionYearlySub, locale)
                    : rc.getText(RemoteConfigKeys.subscriptionMonthlySub, locale),
                onTap: subscription.isPurchasing
                    ? null
                    : () => setState(() => _selectedProductId = product.id),
              ),
            ),
        const SizedBox(height: AppSpacing.md),
        _IncludedFeaturesCard(rc: rc, locale: locale),
        const SizedBox(height: AppSpacing.lg),
        if (subscription.purchaseErrorMessage != null) ...[
          Text(
            subscription.purchaseErrorMessage!,
            textAlign: TextAlign.center,
            style: typography.bodyMedium.copyWith(
              color: colors.error,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        // Bu ekran atlanamaz (bkz. dosya üstü yorumu) — ama salonu abone
        // olmayan bir hesapla girmiş kullanıcı BAŞKA bir hesaba (ör. farklı
        // bir salonun admin'i) geçmek isteyebilir. Bu olmadan uygulamayı
        // silip yeniden yüklemesi gerekirdi. Sadece metin — birincil "başlat"
        // eylemiyle karışmasın diye çerçeve/arka plan yok.
        Center(
          child: TextButton(
            onPressed: subscription.isPurchasing
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
            child: Text(
              ref.watch(rcTextProvider(RemoteConfigKeys.commonCikisYap)),
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _OnboardingCta(
          label: selected == null
              ? '…'
              : subscription.trialUsed
              ? _fill(
                  rc.getText(
                    RemoteConfigKeys.subscriptionOnboardingCtaPaidOnly,
                    locale,
                  ),
                  {'plan': selected.title},
                )
              : _fill(
                  rc.getText(RemoteConfigKeys.subscriptionOnboardingCta, locale),
                  {'plan': selected.title, 'days': days},
                ),
          caption: subscription.trialUsed
              ? _fill(
                  rc.getText(
                    RemoteConfigKeys.subscriptionOnboardingCaptionPaidOnly,
                    locale,
                  ),
                  {'store': _storeName},
                )
              : _fill(
                  rc.getText(RemoteConfigKeys.subscriptionOnboardingCaption, locale),
                  {'days': days, 'store': _storeName},
                ),
          busy: subscription.isPurchasing,
          onTap: _selectedProductId == null || subscription.isPurchasing
              ? null
              : () {
                  final controller = ref.read(
                    subscriptionControllerProvider.notifier,
                  );
                  // GEÇİCİ — mağaza ürünleri henüz canlı değilken (bkz.
                  // SubscriptionPurchaseService.lastFetchWasMock) gerçek
                  // satın alma yerine mock başlatmayı kullan; store
                  // ürünleri canlı olunca bu otomatik olarak gerçek akışa
                  // döner, elle bir şey değiştirmen gerekmez.
                  if (controller.lastFetchWasMock) {
                    controller.startMockSubscription(_selectedProductId!);
                  } else {
                    controller.purchase(_selectedProductId!);
                  }
                },
        ),
      ],
    );
  }
}

class _OnboardingPlanCard extends StatelessWidget {
  const _OnboardingPlanCard({
    required this.product,
    required this.selected,
    required this.busy,
    required this.badge,
    required this.subLabel,
    required this.onTap,
  });

  final SubscriptionProduct product;
  final bool selected;
  final bool busy;
  final String? badge;
  final String subLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Opacity(
      opacity: busy && !selected ? 0.45 : 1,
      child: Material(
        color: selected ? colors.primary.withValues(alpha: 0.08) : colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              border: Border.all(
                color: selected ? colors.primary : colors.outline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? colors.primary : colors.outlineStrong,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.sm,
                        children: [
                          Text(
                            product.title,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 19,
                            ),
                          ),
                          if (badge != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.primary.withValues(alpha: 0.14)
                                    : colors.outline,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                badge!,
                                style: typography.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? colors.secondary
                                      : colors.onSurfaceMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        product.description,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      product.price,
                      style: typography.headingLarge.copyWith(
                        color: colors.onSurface,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      subLabel,
                      style: typography.caption.copyWith(
                        color: selected ? colors.secondary : colors.onSurfaceMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IncludedFeaturesCard extends StatelessWidget {
  const _IncludedFeaturesCard({required this.rc, required this.locale});

  final RemoteConfigService rc;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final items = rc.subscriptionIncludedFeatures
        .map((raw) => (raw['label_$locale'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Container(
              constraints: const BoxConstraints(minHeight: 48),
              decoration: BoxDecoration(
                border: i == items.length - 1
                    ? null
                    : Border(bottom: BorderSide(color: colors.outline)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.success.withValues(alpha: 0.16),
                    ),
                    child: Icon(Icons.check, size: 11, color: colors.success),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      items[i],
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingCta extends StatelessWidget {
  const _OnboardingCta({
    required this.label,
    required this.caption,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final String caption;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final disabled = onTap == null;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppSpacing.primaryActionHeight,
              ),
              decoration: BoxDecoration(
                color: disabled ? colors.surfaceRaised : colors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              ),
              alignment: Alignment.center,
              child: busy
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(colors.onPrimary),
                      ),
                    )
                  : Text(
                      label,
                      style: typography.headingSmall.copyWith(
                        fontSize: 17,
                        color: disabled ? colors.onSurfaceMuted : colors.onPrimary,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
