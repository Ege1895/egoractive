import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/remote_config/remote_config_service.dart';
import '../../core/theme/app_theme.dart';

/// F13-2 — Kullanım Şartları (EULA) ve Gizlilik Politikası bağlantıları.
///
/// Apple Guideline 3.1.2, otomatik yenilenen abonelik satan uygulamalarda
/// bu iki bağlantının BINARY'NİN İÇİNDE bulunmasını şart koşuyor; App Store
/// Connect metadata'sına yazmak yeterli değil. Bu yüzden hem profil
/// ekranında hem de satın alma noktasında (abonelik ekranı) gösteriliyor.
///
/// URL'ler Remote Config'ten, AKTİF DİLE göre geliyor (TR ve EN metinleri
/// ayrı sayfalarda yayınlanıyor) ki adresler store güncellemesi olmadan
/// değiştirilebilsin. **URL boşsa satır hiç gösterilmiyor** — yayına
/// hazır olmayan bir bağlantıyı tıklanabilir yapıp kullanıcıyı boş sayfaya
/// göndermektense gizlemek doğru; ama bu, iki URL de doldurulmadan
/// uygulamanın review'a GÖNDERİLEMEYECEĞİ anlamına gelir.
class LegalLinks extends ConsumerWidget {
  const LegalLinks({this.centered = false, super.key});

  /// Abonelik ekranındaki gibi ortalanmış bir yerleşimde `true`.
  final bool centered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // URL'ler dile göre değişiyor (TR/EN metinleri ayrı sayfalarda
    // yayınlanıyor); `rcTextProvider` aktif dilin sürümünü getirir.
    final termsUrl = ref
        .watch(rcTextProvider(RemoteConfigKeys.commonTermsUrl))
        .trim();
    final privacyUrl = ref
        .watch(rcTextProvider(RemoteConfigKeys.commonPrivacyUrl))
        .trim();
    if (termsUrl.isEmpty && privacyUrl.isEmpty) return const SizedBox.shrink();

    final links = [
      if (termsUrl.isNotEmpty)
        (
          label: ref.watch(rcTextProvider(RemoteConfigKeys.commonTermsNavLabel)),
          url: termsUrl,
        ),
      if (privacyUrl.isNotEmpty)
        (
          label: ref.watch(
            rcTextProvider(RemoteConfigKeys.commonPrivacyNavLabel),
          ),
          url: privacyUrl,
        ),
    ];

    if (centered) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: AppSpacing.md,
        children: [
          for (final link in links)
            _LegalLinkText(label: link.label, url: link.url),
        ],
      );
    }
    return Column(
      children: [
        for (final link in links)
          _LegalNavRow(label: link.label, url: link.url),
      ],
    );
  }
}

/// Bağlantıyı tarayıcıda açar; açılamazsa SESSİZ kalmaz — kullanıcı
/// dokunduğunda hiçbir şey olmaması, bağlantının bozuk olduğunu gizler.
Future<void> _openLegalUrl(BuildContext context, WidgetRef ref, String url) async {
  final uri = Uri.tryParse(url);
  final opened =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (opened || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ref.read(rcTextProvider(RemoteConfigKeys.commonLinkOpenError))),
    ),
  );
}

class _LegalNavRow extends ConsumerWidget {
  const _LegalNavRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return InkWell(
      onTap: () => _openLegalUrl(context, ref, url),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.open_in_new, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _LegalLinkText extends ConsumerWidget {
  const _LegalLinkText({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => _openLegalUrl(context, ref, url),
      child: Text(
        label,
        style: context.appTypography.bodyMedium.copyWith(
          color: context.appColors.onSurfaceMuted,
          fontSize: 12,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
