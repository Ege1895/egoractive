import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/subscription_controller.dart';
import '../../domain/subscription_state.dart';

const _monthNamesShortTr = {
  1: 'Oca', 2: 'Şub', 3: 'Mar', 4: 'Nis', 5: 'May', 6: 'Haz',
  7: 'Tem', 8: 'Ağu', 9: 'Eyl', 10: 'Eki', 11: 'Kas', 12: 'Ara',
};
const _monthNamesLongTr = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};
const _monthNamesShortEn = {
  1: 'Jan', 2: 'Feb', 3: 'Mar', 4: 'Apr', 5: 'May', 6: 'Jun',
  7: 'Jul', 8: 'Aug', 9: 'Sep', 10: 'Oct', 11: 'Nov', 12: 'Dec',
};

/// F6-1 — Admin · Ayarlar > Abonelik. Sadece admin hesapları bu panele
/// ulaşabilir (girişi `AdminSettingsPanel`/`subscription_write_gate.dart`/
/// `subscription_status_banner.dart` — hepsi admin akışına ait).
///
/// Dört durum tasarlanmış (handoff_subscription/Abonelik.dc.html):
/// deneme sürümünde, aktif abone, süresi dolmuş, mağazaya yönlendirildi
/// (satın alma sürüyor). Uygulama içinde ödeme ekranı yok — buton her
/// zaman cihazın kendi mağaza akışını açar.
class SubscriptionPanel extends BasePanel {
  const SubscriptionPanel({super.key});

  @override
  ConsumerState<SubscriptionPanel> createState() => _SubscriptionPanelState();
}

class _SubscriptionPanelState extends BasePanelState<SubscriptionPanel> {
  Future<List<SubscriptionProduct>>? _productsFuture;
  String? _selectedProductId;

  static String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';
  static String get _storeAccountName => Platform.isIOS ? 'Apple' : 'Google';

  @override
  void initState() {
    super.initState();
    _productsFuture = ref.read(subscriptionControllerProvider.notifier).fetchProducts();
  }

  bool _isYearly(String productId) => productId == gymYearlySubscriptionProductId;

  void _ensureSelection(List<SubscriptionProduct> products) {
    if (_selectedProductId != null && products.any((p) => p.id == _selectedProductId)) return;
    final yearly = products.where((p) => _isYearly(p.id)).firstOrNull;
    _selectedProductId = yearly?.id ?? (products.isEmpty ? null : products.first.id);
  }

  String _fill(String template, Map<String, String> values) {
    var result = template;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }

  String _dateLong(DateTime date, String locale) {
    final months = locale == 'tr' ? _monthNamesLongTr : _monthNamesShortEn;
    final month = months[date.month] ?? '';
    return locale == 'tr' ? "${date.day} $month" : '$month ${date.day}';
  }

  String _dateShort(DateTime date, String locale) {
    final months = locale == 'tr' ? _monthNamesShortTr : _monthNamesShortEn;
    final month = months[date.month] ?? '';
    return locale == 'tr' ? '${date.day} $month ${date.year}' : '$month ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final rc = ref.watch(remoteConfigServiceProvider);
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
                  Text('Abonelik', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<SubscriptionProduct>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data ?? const [];
                  _ensureSelection(products);
                  return _buildForState(context, products, subscription, rc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForState(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
  ) {
    if (subscription.isPurchasing) return _pendingView(context, products, subscription, rc);
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return _activeView(context, products, subscription, rc);
      case SubscriptionStatus.expired:
        return _expiredView(context, products, subscription, rc);
      case SubscriptionStatus.trial:
      case SubscriptionStatus.none:
        return _trialView(context, products, subscription, rc);
    }
  }

  // ---- 1 · Deneme sürümünde ----

  Widget _trialView(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
  ) {
    final colors = context.appColors;
    final locale = rc.currentLocale;
    final trialEndsAt = subscription.trialEndsAt;
    final trialStartedAt = subscription.trialStartedAt;
    final totalDays = rc.trialDurationDays;
    final daysRemaining = trialEndsAt == null ? 0 : trialEndsAt.difference(DateTime.now()).inDays.clamp(0, totalDays);
    final currentDay = trialStartedAt == null
        ? totalDays
        : (totalDays - daysRemaining).clamp(1, totalDays);
    final selected = products.where((p) => p.id == _selectedProductId).firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.xl),
      children: [
        _Banner(
          accent: colors.warning,
          leading: _BadgeCircle(color: colors.warning, fg: colors.onPrimary, child: Text('$daysRemaining')),
          title: _fill(rc.getText(RemoteConfigKeys.subscriptionTrialBannerTitle), {'days': '$daysRemaining'}),
          titleColor: colors.warning,
          body: trialEndsAt == null
              ? ''
              : _fill(rc.getText(RemoteConfigKeys.subscriptionTrialBannerBody), {'date': _dateLong(trialEndsAt, locale)}),
          extra: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),
              _ProgressBar(value: currentDay / totalDays, color: colors.warning),
              const SizedBox(height: AppSpacing.xs),
              Text(
                _fill(rc.getText(RemoteConfigKeys.subscriptionTrialProgress), {'total': '$totalDays', 'current': '$currentDay'}),
                style: context.appTypography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (products.isEmpty)
          Text(
            rc.getText(RemoteConfigKeys.subscriptionNoProducts),
            style: context.appTypography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          )
        else
          _PlanList(
            products: products,
            selectedId: _selectedProductId,
            enabled: true,
            isYearly: _isYearly,
            rc: rc,
            onSelect: (id) => setState(() => _selectedProductId = id),
          ),
        const SizedBox(height: AppSpacing.lg),
        _IncludedFeaturesCard(rc: rc, locale: locale),
        const SizedBox(height: AppSpacing.lg),
        _StoreDisclaimer(text: _fill(rc.getText(RemoteConfigKeys.subscriptionStoreNote), _storePlaceholders)),
        const SizedBox(height: AppSpacing.lg),
        _PrimaryCta(
          label: selected == null
              ? '…'
              : _fill(rc.getText(RemoteConfigKeys.subscriptionPurchaseCta), {'plan': selected.title, 'store': _storeName}),
          caption: _fill(rc.getText(RemoteConfigKeys.subscriptionPurchaseCaption), {'store': _storeName}),
          onTap: _selectedProductId == null
              ? null
              : () => ref.read(subscriptionControllerProvider.notifier).purchase(_selectedProductId!),
        ),
      ],
    );
  }

  // ---- 2 · Aktif abone ----

  Widget _activeView(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final locale = rc.currentLocale;
    final productId = subscription.productId;
    final isYearly = productId != null && _isYearly(productId);
    final matchingProduct = products.where((p) => p.id == productId).firstOrNull;
    final planName = matchingProduct?.title ?? (isYearly ? 'Yıllık' : 'Aylık');
    final period = isYearly ? (locale == 'tr' ? 'her yıl' : 'yearly') : (locale == 'tr' ? 'her ay' : 'monthly');

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.xl),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.primary.withValues(alpha: 0.32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rc.getText(RemoteConfigKeys.subscriptionActivePlanLabel),
                          style: typography.bodyMedium.copyWith(color: colors.secondary, fontSize: 13),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(planName, style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 26)),
                        if (matchingProduct != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            matchingProduct.price,
                            style: typography.headingSmall.copyWith(color: colors.onSurfaceVariant, fontSize: 16),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _Pill(
                    label: rc.getText(RemoteConfigKeys.subscriptionActiveBadge),
                    bg: colors.success.withValues(alpha: 0.16),
                    fg: colors.success,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _DateChip(
                      label: rc.getText(RemoteConfigKeys.subscriptionRenewalLabel),
                      value: subscription.expiresAt == null ? '—' : _dateShort(subscription.expiresAt!, locale),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DateChip(
                      label: rc.getText(RemoteConfigKeys.subscriptionStartedLabel),
                      value: subscription.startedAt == null ? '—' : _dateShort(subscription.startedAt!, locale),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _fill(rc.getText(RemoteConfigKeys.subscriptionActiveNote), {'period': period, 'store': _storeName}),
                style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  'STORE',
                  style: typography.headingSmall.copyWith(fontSize: 10, letterSpacing: 0.5, color: colors.onSurfaceVariant),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fill(rc.getText(RemoteConfigKeys.subscriptionStoreRowTitle), {'store': _storeName}),
                      style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _fill(rc.getText(RemoteConfigKeys.subscriptionStoreRowSubtitle), {'storeAccount': _storeAccountName}),
                      style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _IncludedFeaturesCard(rc: rc, locale: locale),
        const SizedBox(height: AppSpacing.lg),
        _SecondaryCta(
          label: rc.getText(RemoteConfigKeys.subscriptionManageCta),
          caption: _fill(rc.getText(RemoteConfigKeys.subscriptionManageCaption), {'store': _storeName}),
          onTap: () {
            // Mağaza abonelik yönetimi ekranı — iOS/Android'in kendi
            // sistem ayarlarına açılır, uygulama içinde bir işlem yok.
          },
        ),
      ],
    );
  }

  // ---- 3 · Süresi dolmuş ----

  Widget _expiredView(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final locale = rc.currentLocale;
    final restricted = rc.subscriptionRestrictedOperations
        .map((raw) => (raw['label_$locale'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final selected = products.where((p) => p.id == _selectedProductId).firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.xl),
      children: [
        _Banner(
          accent: colors.error,
          leading: _BadgeCircle(color: colors.error, fg: colors.onPrimary, child: const Text('!')),
          title: subscription.expiresAt == null
              ? ''
              : _fill(rc.getText(RemoteConfigKeys.subscriptionExpiredBannerTitle), {'date': _dateLong(subscription.expiresAt!, locale)}),
          titleColor: colors.error,
          body: rc.getText(RemoteConfigKeys.subscriptionExpiredBannerBody),
          extra: Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rc.getText(RemoteConfigKeys.subscriptionRestrictedTitle).toUpperCase(),
                  style: typography.headingSmall.copyWith(fontSize: 13, letterSpacing: 1, color: colors.onSurfaceMuted),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final item in restricted)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: colors.error.withValues(alpha: 0.7)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(item, style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                Text(
                  rc.getText(RemoteConfigKeys.subscriptionRestrictedNote),
                  style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (products.isEmpty)
          Text(
            rc.getText(RemoteConfigKeys.subscriptionNoProducts),
            style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          )
        else
          _PlanList(
            products: products,
            selectedId: _selectedProductId,
            enabled: true,
            isYearly: _isYearly,
            rc: rc,
            onSelect: (id) => setState(() => _selectedProductId = id),
          ),
        const SizedBox(height: AppSpacing.lg),
        _StoreDisclaimer(text: _fill(rc.getText(RemoteConfigKeys.subscriptionStoreNoteExpired), _storePlaceholders)),
        const SizedBox(height: AppSpacing.lg),
        _PrimaryCta(
          label: selected == null
              ? '…'
              : _fill(rc.getText(RemoteConfigKeys.subscriptionPurchaseCtaExpired), {'plan': selected.title, 'store': _storeName}),
          caption: _fill(rc.getText(RemoteConfigKeys.subscriptionPurchaseCaption), {'store': _storeName}),
          onTap: _selectedProductId == null
              ? null
              : () => ref.read(subscriptionControllerProvider.notifier).purchase(_selectedProductId!),
        ),
      ],
    );
  }

  // ---- 4 · Mağazaya yönlendirildi (satın alma sürüyor) ----

  Widget _pendingView(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final pendingId = subscription.pendingProductId;

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.xl),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: colors.primary.withValues(alpha: 0.32)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Spinner(size: 26, thickness: 3, color: colors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fill(rc.getText(RemoteConfigKeys.subscriptionPendingBannerTitle), {'store': _storeName}),
                      style: typography.headingSmall.copyWith(color: colors.secondary, fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      rc.getText(RemoteConfigKeys.subscriptionPendingBannerBody),
                      style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PlanList(
          products: products,
          selectedId: pendingId,
          enabled: false,
          isYearly: _isYearly,
          rc: rc,
          onSelect: (_) {},
          pendingId: pendingId,
          pendingLabel: _fill(rc.getText(RemoteConfigKeys.subscriptionPendingPill), {'store': _storeName}),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          rc.getText(RemoteConfigKeys.subscriptionPendingNote),
          style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PendingCta(
          label: _fill(rc.getText(RemoteConfigKeys.subscriptionPendingCta), {'store': _storeName}),
          caption: rc.getText(RemoteConfigKeys.subscriptionPendingCaption),
        ),
      ],
    );
  }

  Map<String, String> get _storePlaceholders => {'store': _storeName, 'storeAccount': _storeAccountName};
}

// ---------------------------------------------------------------------------
// Paylaşılan alt bileşenler
// ---------------------------------------------------------------------------

class _Banner extends StatelessWidget {
  const _Banner({
    required this.accent,
    required this.leading,
    required this.title,
    required this.titleColor,
    required this.body,
    this.extra,
  });

  final Color accent;
  final Widget leading;
  final String title;
  final Color titleColor;
  final String body;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.headingSmall.copyWith(color: titleColor, fontSize: 17)),
                    const SizedBox(height: 3),
                    Text(body, style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          ?extra,
        ],
      ),
    );
  }
}

class _BadgeCircle extends StatelessWidget {
  const _BadgeCircle({required this.color, required this.fg, required this.child});

  final Color color;
  final Color fg;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final typography = context.appTypography;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: DefaultTextStyle(
        style: typography.headingSmall.copyWith(fontSize: 13, color: fg),
        child: child,
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        height: 6,
        color: colors.outlineStrong,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(color: color),
        ),
      ),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.products,
    required this.selectedId,
    required this.enabled,
    required this.isYearly,
    required this.rc,
    required this.onSelect,
    this.pendingId,
    this.pendingLabel,
  });

  final List<SubscriptionProduct> products;
  final String? selectedId;
  final bool enabled;
  final bool Function(String productId) isYearly;
  final RemoteConfigService rc;
  final ValueChanged<String> onSelect;
  final String? pendingId;
  final String? pendingLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final product in products)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _PlanCard(
              product: product,
              selected: product.id == selectedId,
              enabled: enabled,
              badge: isYearly(product.id) ? rc.getText(RemoteConfigKeys.subscriptionYearlyBadge) : null,
              subLabel: isYearly(product.id)
                  ? rc.getText(RemoteConfigKeys.subscriptionYearlySub)
                  : rc.getText(RemoteConfigKeys.subscriptionMonthlySub),
              onTap: enabled ? () => onSelect(product.id) : null,
              pendingLabel: product.id == pendingId ? pendingLabel : null,
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.product,
    required this.selected,
    required this.enabled,
    required this.badge,
    required this.subLabel,
    required this.onTap,
    this.pendingLabel,
  });

  final SubscriptionProduct product;
  final bool selected;
  final bool enabled;
  final String? badge;
  final String subLabel;
  final VoidCallback? onTap;
  final String? pendingLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final dimmed = !enabled && !selected;

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
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
              border: Border.all(color: selected ? colors.primary : colors.outline, width: selected ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          border: Border.all(color: selected ? colors.primary : colors.outlineStrong, width: 2),
                        ),
                        child: selected
                            ? Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary))
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
                              Text(product.title, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 19)),
                              if (badge != null)
                                _Pill(
                                  label: badge!,
                                  bg: selected ? colors.primary.withValues(alpha: 0.14) : colors.outline,
                                  fg: selected ? colors.secondary : colors.onSurfaceMuted,
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(product.description, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 14)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          product.price,
                          style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 22),
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
                if (pendingLabel != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 44),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Spinner(size: 16, thickness: 2, color: colors.secondary),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          pendingLabel!,
                          style: typography.headingSmall.copyWith(color: colors.secondary, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ],
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: colors.success.withValues(alpha: 0.16)),
                    child: Icon(Icons.check, size: 11, color: colors.success),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(items[i], style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StoreDisclaimer extends StatelessWidget {
  const _StoreDisclaimer({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(8)),
            child: Icon(Icons.north_east, size: 14, color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 13, height: 1.5)),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.bg, required this.fg});

  final String label;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
      child: Text(label, style: context.appTypography.caption.copyWith(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
          const SizedBox(height: 3),
          Text(value, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
        ],
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({required this.size, required this.thickness, required this.color});

  final double size;
  final double thickness;
  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: CircularProgressIndicator(
          strokeWidth: widget.thickness,
          color: widget.color,
          backgroundColor: context.appColors.outlineStrong,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({required this.label, required this.caption, required this.onTap});

  final String label;
  final String caption;
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
              constraints: const BoxConstraints(minHeight: AppSpacing.primaryActionHeight),
              decoration: BoxDecoration(
                color: disabled ? colors.surfaceRaised : colors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: typography.headingSmall.copyWith(fontSize: 17, color: disabled ? colors.onSurfaceMuted : colors.onPrimary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.north_east, size: 16, color: disabled ? colors.onSurfaceMuted : colors.onPrimary),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(caption, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
      ],
    );
  }
}

class _SecondaryCta extends StatelessWidget {
  const _SecondaryCta({required this.label, required this.caption, required this.onTap});

  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSpacing.primaryActionHeight),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                border: Border.all(color: colors.outlineStrong),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: typography.headingSmall.copyWith(fontSize: 17, color: colors.onSurface)),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.north_east, size: 16, color: colors.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(caption, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
      ],
    );
  }
}

class _PendingCta extends StatelessWidget {
  const _PendingCta({required this.label, required this.caption});

  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.primaryActionHeight),
          decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Spinner(size: 18, thickness: 2, color: colors.onSurfaceMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(label, style: typography.headingSmall.copyWith(fontSize: 17, color: colors.onSurfaceMuted)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(caption, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
      ],
    );
  }
}
