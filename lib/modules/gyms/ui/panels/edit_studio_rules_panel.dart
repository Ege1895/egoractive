import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/studio_rules_controller.dart';
import '../../domain/studio_rules.dart';

/// Admin 17 · Kuralları Düzenle — serbest metin, cihazın kendi emoji
/// klavyesi kullanılır (özel bir editör/emoji seçici gerekmiyor).
class EditStudioRulesPanel extends BasePanel {
  const EditStudioRulesPanel({super.key});

  @override
  ConsumerState<EditStudioRulesPanel> createState() => _EditStudioRulesPanelState();
}

class _EditStudioRulesPanelState extends BasePanelState<EditStudioRulesPanel> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: ref.read(studioRulesControllerProvider).text);
    _textController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final length = _textController.text.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Kuralları düzenle', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                  GestureDetector(
                    onTap: () => ref.read(panelStackControllerProvider.notifier).pop(),
                    child: Text('Vazgeç', style: typography.bodyLarge.copyWith(color: colors.onSurfaceMuted, fontSize: 15)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Serbest metin: satır atlayabilir, paragraf bırakabilir, klavyenin emoji tuşunu kullanabilirsiniz. Üyeler tam olarak yazdığınız gibi görür.",
                      style: typography.caption.copyWith(color: colors.onSurfaceMuted, height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLength: studioRulesMaxLength,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15, height: 1.65),
                          decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('$length / $studioRulesMaxLength karakter', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(
                label: 'Kaydet',
                onPressed: () {
                  ref.read(studioRulesControllerProvider.notifier).updateText(_textController.text);
                  ref.read(panelStackControllerProvider.notifier).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
