import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_confirm_dialog.dart';
import '../../controller/gym_theme_controller.dart';
import '../../domain/gym_theme.dart';
import 'add_gym_theme_panel.dart';

/// Admin · Temalar — kayıtlı tema listesi, seçilen tema tüm üyelere uygulanır.
class GymThemesPanel extends BasePanel {
  const GymThemesPanel({super.key});

  @override
  ConsumerState<GymThemesPanel> createState() => _GymThemesPanelState();
}

class _GymThemesPanelState extends BasePanelState<GymThemesPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(gymThemeControllerProvider);
    final controller = ref.read(gymThemeControllerProvider.notifier);
    final active = controller.activeTheme;

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
                    ref.watch(rcTextProvider(RemoteConfigKeys.gymsThemesTitle)),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.gymsThemesDescription),
                    ),
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      state.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  for (final theme in state.themes)
                    _ThemeRow(
                      name: _resolvedPresetName(theme),
                      note: _resolvedPresetNote(theme),
                      primary: theme.primary,
                      soft: theme.soft,
                      selected: theme.id == state.activeThemeId,
                      onTap: () => controller.selectTheme(theme.id),
                      // Hazır temalarda buton hiç çizilmiyor (bkz.
                      // `isGymThemeDeletable`) — pasif bir buton göstermek,
                      // "neden çalışmıyor?" sorusunu doğururdu.
                      onDelete: isGymThemeDeletable(theme.id)
                          ? () => _confirmDeleteTheme(theme)
                          : null,
                      deleteLabel: ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.gymsThemesDeleteButtonLabel,
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(const AddGymThemePanel()),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 52),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.45),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsThemesAddThemeButton,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            fontSize: 15,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsThemesMemberPreviewSection,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusInner,
                            ),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: active.primary,
                                    width: 3,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '6',
                                  style: typography.dataMedium.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .gymsThemePreviewRemainingSessionsLabel,
                                        ),
                                      ),
                                      style: typography.headingSmall.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .gymsThemePreviewNextSessionLabel,
                                        ),
                                      ),
                                      style: typography.bodyMedium.copyWith(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Material(
                          color: active.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.center,
                            child: Text(
                              ref.watch(
                                rcTextProvider(RemoteConfigKeys.commonGelicem),
                              ),
                              style: typography.headingSmall.copyWith(
                                fontSize: 15,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 68),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .gymsThemesShowLogoSilhouetteToggleLabel,
                                    ),
                                  ),
                                  style: typography.bodyLarge.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .gymsThemesShowLogoSilhouetteToggleDescription,
                                    ),
                                  ),
                                  style: typography.caption.copyWith(
                                    color: colors.onSurfaceMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.toggleWatermark,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 52,
                              height: 32,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: state.watermarkEnabled
                                    ? colors.primary
                                    : colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              alignment: state.watermarkEnabled
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: colors.onSurface,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              // Seçim yukarıda dokunulduğu anda zaten uygulanıp kaydediliyor
              // (selectTheme) — bu buton ayrı bir "uygula" işlemi yapmıyor,
              // sadece ekranı kapatıyor; eski etiket ("...uygula") bunun
              // ayrı bir onay adımıymış gibi yanıltıyordu.
              child: AppButton(
                label: ref.watch(
                  rcTextProvider(RemoteConfigKeys.gymsPermissionsDoneButton),
                ),
                onPressed: () =>
                    ref.read(panelStackControllerProvider.notifier).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Yerleşik 3 varsayılan preset (`GymThemeService._defaultPresets`) ve
  /// logo renginden otomatik oluşturulan temanın (`id` her zaman `logo-`
  /// ile başlar) adı/notu Firestore'a o anki dilde YAZILIYOR — bu yüzden
  /// gösterimde tekrar dile göre çözülmesi gerekiyor. Kullanıcının kendi
  /// yazdığı özel tema adları (diğer tüm id'ler) veri olarak kalır,
  /// çevrilmez.
  /// Geri alınamaz aksiyon: ortak onay diyaloğu (`showAppConfirmDialog`)
  /// kullanılıyor — diyalog, silme TAMAMLANANA kadar açık kalıyor ve hata
  /// olursa kendi içinde gösterip tekrar denemeye izin veriyor.
  Future<void> _confirmDeleteTheme(GymTheme theme) async {
    await showAppConfirmDialog(
      context: context,
      title: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsThemesDeleteConfirmTitle),
      ),
      message: ref
          .read(rcTextProvider(RemoteConfigKeys.gymsThemesDeleteConfirmBody))
          .replaceAll('{name}', _resolvedPresetName(theme)),
      confirmLabel: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsThemesDeleteConfirmCta),
      ),
      cancelLabel: ref.read(
        rcTextProvider(RemoteConfigKeys.commonCancelButton),
      ),
      busyLabel: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsThemesDeleteBusyLabel),
      ),
      errorMessage: ref.read(
        rcTextProvider(RemoteConfigKeys.gymsThemesDeleteError),
      ),
      onConfirm: () =>
          ref.read(gymThemeControllerProvider.notifier).deleteTheme(theme.id),
    );
  }

  String _resolvedPresetName(GymTheme theme) {
    final key = _presetNameKey(theme.id);
    return key == null ? theme.name : ref.watch(rcTextProvider(key));
  }

  String _resolvedPresetNote(GymTheme theme) {
    final key = _presetNoteKey(theme.id);
    return key == null ? theme.note : ref.watch(rcTextProvider(key));
  }
}

String? _presetNameKey(String themeId) => switch (themeId) {
  'egora-mavisi' => RemoteConfigKeys.gymsThemePresetDefaultName,
  'turuncu-enerji' => RemoteConfigKeys.gymsThemePresetOrangeName,
  'yesil-doga' => RemoteConfigKeys.gymsThemePresetGreenName,
  _ when themeId.startsWith('logo-') =>
    RemoteConfigKeys.gymsGymInfoLogoColorThemeName,
  _ => null,
};

String? _presetNoteKey(String themeId) => switch (themeId) {
  'egora-mavisi' => RemoteConfigKeys.gymsThemePresetDefaultNote,
  'turuncu-enerji' => RemoteConfigKeys.gymsThemePresetOrangeNote,
  'yesil-doga' => RemoteConfigKeys.gymsThemePresetGreenNote,
  _ when themeId.startsWith('logo-') =>
    RemoteConfigKeys.gymsGymInfoLogoColorThemeNote,
  _ => null,
};

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.name,
    required this.note,
    required this.primary,
    required this.soft,
    required this.selected,
    required this.onTap,
    required this.deleteLabel,
    this.onDelete,
  });

  final String name;
  final String note;
  final Color primary;
  final Color soft;
  final bool selected;
  final VoidCallback onTap;

  /// `null` ise bu tema silinemez (hazır temalar) ve eksi butonu çizilmez.
  final VoidCallback? onDelete;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      // Eksi butonu kartın SAĞ ÜSTÜNE bindiriliyor; kartın kendi
      // `InkWell`'i tüm alanı kapladığı için Stack'te ondan SONRA gelmesi
      // şart, aksi halde dokunuşu alttaki "temayı seç" davranışı yutardı.
      child: Stack(
        children: [
          Material(
            color: selected ? primary.withValues(alpha: 0.1) : colors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(
                    color: selected
                        ? primary.withValues(alpha: 0.5)
                        : colors.outline,
                  ),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: soft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: typography.headingSmall.copyWith(
                              color: colors.onSurface,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            note,
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? primary : colors.outlineStrong,
                          width: 2,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: selected
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary,
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: Semantics(
                button: true,
                label: deleteLabel,
                child: Tooltip(
                  message: deleteLabel,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onDelete,
                      // Dokunma alanı görünen daireden büyük: 22px'lik bir
                      // ikon parmakla ıskalanır (Material'ın önerdiği asgari
                      // 48px'e yakın tutuluyor).
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.remove_circle_outline,
                          size: 20,
                          // Yıkıcı bir aksiyon ama her satırda bir tane var;
                          // kırmızı kullanmak listeyi görsel olarak
                          // bağırtırdı. Uyarı rengi, asıl kararın verildiği
                          // onay diyaloğunda kullanılıyor.
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
