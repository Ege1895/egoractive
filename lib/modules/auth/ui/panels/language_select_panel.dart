import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';

/// Üye/antrenör profil ve admin ayarlar ekranlarındaki "Dil / Language"
/// satırının hedefi. Seçim anında [localeControllerProvider] güncellenir —
/// bunu `watch` eden `rcTextProvider` tabanlı tüm metinler ve
/// `MaterialApp.locale` reaktif olarak yeniden çizilir.
class LanguageSelectPanel extends BasePanel {
  const LanguageSelectPanel({super.key});

  @override
  ConsumerState<LanguageSelectPanel> createState() =>
      _LanguageSelectPanelState();
}

class _LanguageSelectPanelState extends BasePanelState<LanguageSelectPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    final activeLocale = ref.watch(localeControllerProvider);

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
                  AppBackButton(onTap: () => panelStack.pop()),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.languageSelectTitle),
                    ),
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenEdge,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  children: [
                    _LanguageRow(
                      label: ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.languageSelectTurkishOption,
                        ),
                      ),
                      selected: activeLocale == 'tr',
                      onTap: () => ref
                          .read(localeControllerProvider.notifier)
                          .setLanguage('tr'),
                    ),
                    _LanguageRow(
                      label: ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.languageSelectEnglishOption,
                        ),
                      ),
                      selected: activeLocale == 'en',
                      isLast: true,
                      onTap: () => ref
                          .read(localeControllerProvider.notifier)
                          .setLanguage('en'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.selected,
    required this.onTap,
    this.isLast = false,
  });

  final String label;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: colors.outline)),
        ),
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
            if (selected) Icon(Icons.check, color: colors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
