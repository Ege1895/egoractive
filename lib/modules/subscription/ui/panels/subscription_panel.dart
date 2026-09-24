import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/subscription_constants.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/legal_links.dart';
import '../../controller/subscription_controller.dart';
import '../../domain/subscription_state.dart';
import '../../../../shared/utils/date_labels.dart';

/// Mağazadan gerçek ücretsiz deneme süresi okunabildiyse (bkz.
/// `SubscriptionProduct.trialDays`) onu gösterir — hardcode "aylık"/"2 ay
/// bedava" metinleri sadece mağaza bu bilgiyi döndürmediğinde (fallback)
/// kullanılır. `_PlanList` ve aktif abone ekranındaki yıllığa geçiş kartı
/// aynı mantığı paylaşır.
String _planSubLabel(
  SubscriptionProduct product,
  bool isYearly,
  RemoteConfigService rc,
  String locale,
) {
  final days = product.trialDays;
  if (days != null) {
    return rc
        .getText(RemoteConfigKeys.subscriptionTrialSubLabel, locale)
        .replaceAll('{days}', '$days');
  }
  return isYearly
      ? rc.getText(RemoteConfigKeys.subscriptionYearlySub, locale)
      : rc.getText(RemoteConfigKeys.subscriptionMonthlySub, locale);
}

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

  /// Aktif abone ekranında (aylık planı olan kullanıcıya) sunulan yıllığa
  /// geçiş kartının seçili olup olmadığı — panel bu ekranın üstüne başka
  /// bir panel push edilip geri dönüldüğünde bile canlı kaldığından
  /// (`BasePanel` state'i dispose etmiyor), her yeniden gösterimde
  /// [onPanelShow] ile bilerek sıfırlanıyor.
  bool _yearlyUpgradeSelected = false;

  static String get _storeName => Platform.isIOS ? 'App Store' : 'Google Play';
  static String get _storeAccountName => Platform.isIOS ? 'Apple' : 'Google';

  @override
  void initState() {
    super.initState();
    _productsFuture = ref
        .read(subscriptionControllerProvider.notifier)
        .fetchProducts();
  }

  @override
  void onPanelShow() {
    if (_yearlyUpgradeSelected) {
      setState(() => _yearlyUpgradeSelected = false);
    }
  }

  bool _isYearly(String productId) =>
      productId == gymYearlySubscriptionProductId;

  /// Satın alma CTA'sındaki `{plan}` yer tutucusu için — mağazadan gelen ham
  /// ürün başlığı ("Egoractive Business — Yıllık" gibi) yerine sadece
  /// "Yıllık"/"Aylık" kısa kelimesi kullanılır, aksi halde buton metni
  /// ("Egoractive Business — Yıllık planla App Store'a git") taşıyordu.
  String _planWord(String productId) => ref.watch(
    rcTextProvider(
      _isYearly(productId)
          ? RemoteConfigKeys.subscriptionYearlyPlanFallback
          : RemoteConfigKeys.subscriptionMonthlyPlanFallback,
    ),
  );

  void _ensureSelection(List<SubscriptionProduct> products) {
    if (_selectedProductId != null &&
        products.any((p) => p.id == _selectedProductId))
      return;
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

  // Ay adı ve gün/ay sırası artık `DateLabels` üzerinden RC'den geliyor —
  // burada `locale == 'tr'` diye dallanan iki ayrı map tutulmuyor.
  String _dateLong(DateTime date, DateLabels labels) =>
      labels.dayMonthLong(date);

  String _dateShort(DateTime date, DateLabels labels) =>
      labels.dayMonthYear(date);

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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  AppBackButton(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsSettingsNavSubscription,
                      ),
                    ),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              // Exempt salon da artık mağaza ürünlerini bekliyor: planı
              // gerçek fiyat/deneme bilgisiyle göstermek için (önceden
              // sadece "Yıllık" kelimesi yazıyordu).
              child: FutureBuilder<List<SubscriptionProduct>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final products = snapshot.data ?? const [];
                  if (subscription.subscriptionExempt) {
                    return _exemptView(context, rc, products);
                  }
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
    if (subscription.isPurchasing)
      return _pendingView(context, products, subscription, rc);
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return _activeView(context, products, subscription, rc);
      case SubscriptionStatus.expired:
      case SubscriptionStatus.pastDue:
      case SubscriptionStatus.canceled:
        return _expiredView(context, products, subscription, rc);
      case SubscriptionStatus.trial:
      case SubscriptionStatus.none:
        return _trialView(context, products, subscription, rc);
    }
  }

  // ---- 0 · Ödeme yapmayacak salon (subscriptionExempt) ----

  /// `gyms/{gymId}.subscriptionExempt == true` — sadece Firebase
  /// Console/Admin SDK'dan elle set edilir (bkz. [SubscriptionState]).
  /// Ekran BİLEREK [_activeView]'in kart yapısını (rozet + başlık + tarih
  /// kutuları) birebir kullanır ki bu gösterim, gerçekten abone bir salonun
  /// ekranından görsel olarak ayırt edilemesin (ör. reklam amaçlı geçici
  /// ücretsiz erişim verilen bir salonun panelinde) — AMA `gyms/{gymId}`'ye
  /// asla gerçek bir abonelik yazılmıyor: tarih kutuları hep "—" gösterir,
  /// fiyat satırı hiç yok, "Aboneliği yönet" (App Store'a giden) butonu da
  /// yok, çünkü yönetilecek gerçek bir abonelik yok. Bu SADECE görsel bir
  /// gösterim — `subscriptionExempt` `false`'a çekildiğinde `gyms/{gymId}`'de
  /// hiçbir gerçek `subscriptionStatus`/`subscriptionProductId` olmadığı
  /// için salon otomatik olarak (appAccess üzerinden) zorunlu abonelik
  /// seçim ekranına düşer — tam istenen davranış.
  Widget _exemptView(
    BuildContext context,
    RemoteConfigService rc,
    List<SubscriptionProduct> products,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final locale = ref.watch(localeControllerProvider);
    // Mağazadan gelen GERÇEK yıllık ürün — fiyat, açıklama ve deneme
    // etiketiyle birlikte gösterilir. Mağaza henüz yanıt vermediyse ya da
    // ürün bulunamadıysa (ör. store kurulumu tamamlanmamış) eski davranışa,
    // yani sadece "Yıllık" kelimesine düşülür.
    final yearlyProduct = products.where((p) => _isYearly(p.id)).firstOrNull;
    final planName = ref.watch(
      rcTextProvider(RemoteConfigKeys.subscriptionYearlyPlanFallback),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
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
                          rc.getText(
                            RemoteConfigKeys.subscriptionActivePlanLabel,
                            locale,
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.secondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          yearlyProduct?.title ?? planName,
                          style: typography.headingLarge.copyWith(
                            color: colors.onSurface,
                            fontSize: yearlyProduct == null ? 26 : 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Pill(
                    label: rc.getText(
                      RemoteConfigKeys.subscriptionActiveBadge,
                      locale,
                    ),
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
                      label: rc.getText(
                        RemoteConfigKeys.subscriptionRenewalLabel,
                        locale,
                      ),
                      value: '—',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DateChip(
                      label: rc.getText(
                        RemoteConfigKeys.subscriptionStartedLabel,
                        locale,
                      ),
                      value: '—',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                rc.getText(RemoteConfigKeys.subscriptionExemptNote, locale),
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        // Mağazadan çekilen gerçek plan kartı — fiyat, "2 ay bedava" gibi
        // deneme etiketi ve açıklama dahil. `showSelector: false`: bu bir
        // seçenek değil, salonun sahip olduğu planın gösterimi (seçilecek
        // bir şey yok, dokunulamaz).
        if (yearlyProduct != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _PlanCard(
            product: yearlyProduct,
            selected: true,
            enabled: true,
            showSelector: false,
            onTap: null,
            badge: rc.getText(RemoteConfigKeys.subscriptionYearlyBadge, locale),
            subLabel: _planSubLabel(yearlyProduct, true, rc, locale),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _IncludedFeaturesCard(rc: rc, locale: locale),
      ],
    );
  }

  // ---- 1 · Deneme sürümünde ----

  Widget _trialView(
    BuildContext context,
    List<SubscriptionProduct> products,
    SubscriptionState subscription,
    RemoteConfigService rc,
  ) {
    final colors = context.appColors;
    final locale = ref.watch(localeControllerProvider);
    final selected = products
        .where((p) => p.id == _selectedProductId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
      children: [
        if (products.isEmpty)
          Text(
            rc.getText(RemoteConfigKeys.subscriptionNoProducts, locale),
            style: context.appTypography.bodyMedium.copyWith(
              color: colors.onSurfaceMuted,
            ),
          )
        else
          _PlanList(
            products: products,
            selectedId: _selectedProductId,
            enabled: true,
            isYearly: _isYearly,
            rc: rc,
            locale: locale,
            onSelect: (id) => setState(() => _selectedProductId = id),
          ),
        const SizedBox(height: AppSpacing.lg),
        _IncludedFeaturesCard(rc: rc, locale: locale),
        const SizedBox(height: AppSpacing.lg),
        _StoreDisclaimer(
          text: _fill(
            rc.getText(RemoteConfigKeys.subscriptionStoreNote, locale),
            _storePlaceholders,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (subscription.purchaseErrorMessage != null) ...[
          Text(
            subscription.purchaseErrorMessage!,
            textAlign: TextAlign.center,
            style: context.appTypography.bodyMedium.copyWith(
              color: colors.error,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        _PrimaryCta(
          label: selected == null
              ? '…'
              : _fill(
                  rc.getText(RemoteConfigKeys.subscriptionPurchaseCta, locale),
                  {'plan': _planWord(selected.id), 'store': _storeName},
                ),
          caption: _fill(
            rc.getText(RemoteConfigKeys.subscriptionPurchaseCaption, locale),
            {'store': _storeName},
          ),
          onTap: _selectedProductId == null
              ? null
              : () => _purchaseOrMockStart(_selectedProductId!),
        ),
        _RestorePurchasesRow(subscription: subscription),
        // F13-2 — Apple 3.1.2, bu bağlantıların SATIN ALMA NOKTASINDA da
        // bulunmasını istiyor; profil ekranındaki kopya tek başına yeterli
        // sayılmıyor.
        const LegalLinks(centered: true),
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
    final locale = ref.watch(localeControllerProvider);
    final dateLabels = ref.watch(dateLabelsProvider);
    final productId = subscription.productId;
    final isYearly = productId != null && _isYearly(productId);
    final matchingProduct = products
        .where((p) => p.id == productId)
        .firstOrNull;
    final String planNameFallback = ref.watch(
      rcTextProvider(
        isYearly
            ? RemoteConfigKeys.subscriptionYearlyPlanFallback
            : RemoteConfigKeys.subscriptionMonthlyPlanFallback,
      ),
    );
    final String planName = matchingProduct?.title ?? planNameFallback;
    final period = ref.watch(
      rcTextProvider(
        isYearly
            ? RemoteConfigKeys.subscriptionYearlyPeriodWord
            : RemoteConfigKeys.subscriptionMonthlyPeriodWord,
      ),
    );
    // Zaten yıllık plana abone olan kullanıcıya "yıllığa geç" teklifi
    // gösterilmez — sadece aylık abonelere, ve mağazada gerçekten yıllık
    // ürün dönüyorsa (mock/Android henüz kurulmadıysa gösterilmez).
    final yearlyProduct = products.where((p) => _isYearly(p.id)).firstOrNull;
    final showYearlyUpgrade = !isYearly && yearlyProduct != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
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
                          rc.getText(
                            RemoteConfigKeys.subscriptionActivePlanLabel,
                            locale,
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.secondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          planName,
                          style: typography.headingLarge.copyWith(
                            color: colors.onSurface,
                            fontSize: 26,
                          ),
                        ),
                        if (matchingProduct != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            matchingProduct.price,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _Pill(
                    label: rc.getText(
                      RemoteConfigKeys.subscriptionActiveBadge,
                      locale,
                    ),
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
                      label: rc.getText(
                        RemoteConfigKeys.subscriptionRenewalLabel,
                        locale,
                      ),
                      value: subscription.expiresAt == null
                          ? '—'
                          : _dateShort(subscription.expiresAt!, dateLabels),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _DateChip(
                      label: rc.getText(
                        RemoteConfigKeys.subscriptionStartedLabel,
                        locale,
                      ),
                      value: subscription.startedAt == null
                          ? '—'
                          : _dateShort(subscription.startedAt!, dateLabels),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _fill(
                  rc.getText(RemoteConfigKeys.subscriptionActiveNote, locale),
                  {'period': period, 'store': _storeName},
                ),
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _IncludedFeaturesCard(rc: rc, locale: locale),
        if (showYearlyUpgrade) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            rc.getText(
              RemoteConfigKeys.subscriptionUpgradeToYearlyTitle,
              locale,
            ),
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PlanCard(
            product: yearlyProduct,
            selected: _yearlyUpgradeSelected,
            enabled: true,
            badge: rc.getText(RemoteConfigKeys.subscriptionYearlyBadge, locale),
            subLabel: _planSubLabel(yearlyProduct, true, rc, locale),
            onTap: () => setState(
              () => _yearlyUpgradeSelected = !_yearlyUpgradeSelected,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (showYearlyUpgrade && _yearlyUpgradeSelected)
          _PrimaryCta(
            label: _fill(
              rc.getText(RemoteConfigKeys.subscriptionPurchaseCta, locale),
              {'plan': _planWord(yearlyProduct.id), 'store': _storeName},
            ),
            caption: _fill(
              rc.getText(RemoteConfigKeys.subscriptionPurchaseCaption, locale),
              {'store': _storeName},
            ),
            onTap: () => _purchaseOrMockStart(yearlyProduct.id),
          )
        else
          _SecondaryCta(
            label: rc.getText(RemoteConfigKeys.subscriptionManageCta, locale),
            caption: _fill(
              rc.getText(RemoteConfigKeys.subscriptionManageCaption, locale),
              {'store': _storeName},
            ),
            onTap: _openStoreSubscriptionManagement,
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
    final locale = ref.watch(localeControllerProvider);
    final dateLabels = ref.watch(dateLabelsProvider);
    final restricted = rc.subscriptionRestrictedOperations
        .map((raw) => (raw['label_$locale'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
    final selected = products
        .where((p) => p.id == _selectedProductId)
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
      children: [
        _Banner(
          accent: colors.error,
          leading: _BadgeCircle(
            color: colors.error,
            fg: colors.onPrimary,
            child: const Text('!'),
          ),
          title: subscription.expiresAt == null
              ? ''
              : _fill(
                  rc.getText(
                    RemoteConfigKeys.subscriptionExpiredBannerTitle,
                    locale,
                  ),
                  {'date': _dateLong(subscription.expiresAt!, dateLabels)},
                ),
          titleColor: colors.error,
          body: rc.getText(
            RemoteConfigKeys.subscriptionExpiredBannerBody,
            locale,
          ),
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
                  rc
                      .getText(
                        RemoteConfigKeys.subscriptionRestrictedTitle,
                        locale,
                      )
                      .toUpperCase(),
                  style: typography.headingSmall.copyWith(
                    fontSize: 13,
                    letterSpacing: 1,
                    color: colors.onSurfaceMuted,
                  ),
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
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.error.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            item,
                            style: typography.bodyMedium.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  rc.getText(
                    RemoteConfigKeys.subscriptionRestrictedNote,
                    locale,
                  ),
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (products.isEmpty)
          Text(
            rc.getText(RemoteConfigKeys.subscriptionNoProducts, locale),
            style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
          )
        else
          _PlanList(
            products: products,
            selectedId: _selectedProductId,
            enabled: true,
            isYearly: _isYearly,
            rc: rc,
            locale: locale,
            onSelect: (id) => setState(() => _selectedProductId = id),
          ),
        const SizedBox(height: AppSpacing.lg),
        _StoreDisclaimer(
          text: _fill(
            rc.getText(RemoteConfigKeys.subscriptionStoreNoteExpired, locale),
            _storePlaceholders,
          ),
        ),
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
        _PrimaryCta(
          label: selected == null
              ? '…'
              : _fill(
                  rc.getText(
                    RemoteConfigKeys.subscriptionPurchaseCtaExpired,
                    locale,
                  ),
                  {'plan': _planWord(selected.id), 'store': _storeName},
                ),
          caption: _fill(
            rc.getText(RemoteConfigKeys.subscriptionPurchaseCaption, locale),
            {'store': _storeName},
          ),
          onTap: _selectedProductId == null
              ? null
              : () => _purchaseOrMockStart(_selectedProductId!),
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
    final locale = ref.watch(localeControllerProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.md,
        AppSpacing.screenEdge,
        AppSpacing.xl,
      ),
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
                      _fill(
                        rc.getText(
                          RemoteConfigKeys.subscriptionPendingBannerTitle,
                          locale,
                        ),
                        {'store': _storeName},
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.secondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      rc.getText(
                        RemoteConfigKeys.subscriptionPendingBannerBody,
                        locale,
                      ),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
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
          locale: locale,
          onSelect: (_) {},
          pendingId: pendingId,
          pendingLabel: _fill(
            rc.getText(RemoteConfigKeys.subscriptionPendingPill, locale),
            {'store': _storeName},
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          rc.getText(RemoteConfigKeys.subscriptionPendingNote, locale),
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _PendingCta(
          label: _fill(
            rc.getText(RemoteConfigKeys.subscriptionPendingCta, locale),
            {'store': _storeName},
          ),
          caption: rc.getText(
            RemoteConfigKeys.subscriptionPendingCaption,
            locale,
          ),
        ),
      ],
    );
  }

  Map<String, String> get _storePlaceholders => {
    'store': _storeName,
    'storeAccount': _storeAccountName,
  };

  /// GEÇİCİ — mağaza ürünleri henüz canlı değilken (bkz.
  /// `SubscriptionPurchaseService.lastFetchWasMock`) gerçek satın alma
  /// yerine mock başlatmayı kullan; store canlı olunca otomatik gerçek
  /// akışa döner.
  void _purchaseOrMockStart(String productId) {
    final controller = ref.read(subscriptionControllerProvider.notifier);
    if (controller.lastFetchWasMock) {
      controller.startMockSubscription(productId);
    } else {
      controller.purchase(productId);
    }
  }

  /// "Aboneliği yönet" — cihazın kendi abonelik yönetim sayfasını açar.
  /// Uygulama içinde plan değişikliği/iptal işlemi yok, hepsi mağazada.
  Future<void> _openStoreSubscriptionManagement() async {
    final uri = Platform.isIOS
        ? Uri.parse('https://apps.apple.com/account/subscriptions')
        : Uri.parse(
            'https://play.google.com/store/account/subscriptions?package=$androidPackageName',
          );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ref.read(
              rcTextProvider(RemoteConfigKeys.subscriptionManagementOpenError),
            ),
          ),
        ),
      );
    }
  }
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
                    Text(
                      title,
                      style: typography.headingSmall.copyWith(
                        color: titleColor,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
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
  const _BadgeCircle({
    required this.color,
    required this.fg,
    required this.child,
  });

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

class _PlanList extends StatelessWidget {
  const _PlanList({
    required this.products,
    required this.selectedId,
    required this.enabled,
    required this.isYearly,
    required this.rc,
    required this.locale,
    required this.onSelect,
    this.pendingId,
    this.pendingLabel,
  });

  final List<SubscriptionProduct> products;
  final String? selectedId;
  final bool enabled;
  final bool Function(String productId) isYearly;
  final RemoteConfigService rc;
  final String locale;
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
              badge: isYearly(product.id)
                  ? rc.getText(RemoteConfigKeys.subscriptionYearlyBadge, locale)
                  : null,
              subLabel: _planSubLabel(
                product,
                isYearly(product.id),
                rc,
                locale,
              ),
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
    this.showSelector = true,
  });

  final SubscriptionProduct product;
  final bool selected;
  final bool enabled;
  final String? badge;
  final String subLabel;
  final VoidCallback? onTap;
  final String? pendingLabel;

  /// `false` ise seçim dairesi (radio) hiç çizilmez — kart bir SEÇENEK değil,
  /// "sahip olunan plan"ın gösterimi olduğunda kullanılır (bkz.
  /// `_exemptView`: ödeme yapmayacak salona planı olduğu gibi gösteriliyor,
  /// ama seçilecek bir şey yok).
  final bool showSelector;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final dimmed = !enabled && !selected;

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: Material(
        color: selected
            ? colors.primary.withValues(alpha: 0.08)
            : colors.surface,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSelector) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? colors.primary
                                  : colors.outlineStrong,
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
                    ],
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
                                _Pill(
                                  label: badge!,
                                  bg: selected
                                      ? colors.primary.withValues(alpha: 0.14)
                                      : colors.outline,
                                  fg: selected
                                      ? colors.secondary
                                      : colors.onSurfaceMuted,
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
                            color: selected
                                ? colors.secondary
                                : colors.onSurfaceMuted,
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
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _Spinner(
                          size: 16,
                          thickness: 2,
                          color: colors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          pendingLabel!,
                          style: typography.headingSmall.copyWith(
                            color: colors.secondary,
                            fontSize: 15,
                          ),
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
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.north_east,
              size: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: typography.caption.copyWith(
                color: colors.onSurfaceMuted,
                fontSize: 13,
                height: 1.5,
              ),
            ),
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
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: context.appTypography.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
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
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(
              color: colors.onSurfaceMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: typography.headingSmall.copyWith(
              color: colors.onSurface,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _Spinner extends StatefulWidget {
  const _Spinner({
    required this.size,
    required this.thickness,
    required this.color,
  });

  final double size;
  final double thickness;
  final Color color;

  @override
  State<_Spinner> createState() => _SpinnerState();
}

class _SpinnerState extends State<_Spinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
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
  const _PrimaryCta({
    required this.label,
    required this.caption,
    required this.onTap,
  });

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
              constraints: const BoxConstraints(
                minHeight: AppSpacing.primaryActionHeight,
              ),
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
                    style: typography.headingSmall.copyWith(
                      fontSize: 17,
                      color: disabled
                          ? colors.onSurfaceMuted
                          : colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.north_east,
                    size: 16,
                    color: disabled ? colors.onSurfaceMuted : colors.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _SecondaryCta extends StatelessWidget {
  const _SecondaryCta({
    required this.label,
    required this.caption,
    required this.onTap,
  });

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
              constraints: const BoxConstraints(
                minHeight: AppSpacing.primaryActionHeight,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                border: Border.all(color: colors.outlineStrong),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: typography.headingSmall.copyWith(
                      fontSize: 17,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.north_east,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
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
          constraints: const BoxConstraints(
            minHeight: AppSpacing.primaryActionHeight,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceRaised,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Spinner(size: 18, thickness: 2, color: colors.onSurfaceMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: typography.headingSmall.copyWith(
                  fontSize: 17,
                  color: colors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          caption,
          style: typography.caption.copyWith(
            color: colors.onSurfaceMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}


/// F13-1 — Apple Guideline 3.1.1: "Satın alımları geri yükle".
///
/// Abonelik satın alma noktasında görünür olmalı; reviewer bunu bizzat
/// deniyor (ikinci cihaz ya da sil-kur). Sonuç mesajı hem başarıyı hem
/// "satın alım bulunamadı" durumunu kapsıyor — ikincisi bir HATA değil,
/// bu yüzden hata rengiyle değil normal metin rengiyle gösteriliyor.
class _RestorePurchasesRow extends ConsumerWidget {
  const _RestorePurchasesRow({required this.subscription});

  final SubscriptionState subscription;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          if (subscription.restoreMessage != null) ...[
            Text(
              subscription.restoreMessage!,
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurfaceMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          TextButton(
            onPressed: subscription.isRestoring
                ? null
                : () => ref
                      .read(subscriptionControllerProvider.notifier)
                      .restorePurchases(),
            child: Text(
              ref.watch(
                rcTextProvider(
                  subscription.isRestoring
                      ? RemoteConfigKeys.subscriptionRestoreInProgress
                      : RemoteConfigKeys.subscriptionRestoreButton,
                ),
              ),
              style: typography.bodyMedium.copyWith(
                color: subscription.isRestoring
                    ? colors.onSurfaceMuted
                    : colors.primary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
