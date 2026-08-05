import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/studio_rules_controller.dart';
import 'edit_studio_rules_panel.dart';

/// Admin 16 · Stüdyo Kuralları (görüntüleme) — üyenin de gördüğü hâl.
class StudioRulesPanel extends BasePanel {
  const StudioRulesPanel({super.key});

  @override
  ConsumerState<StudioRulesPanel> createState() => _StudioRulesPanelState();
}

class _StudioRulesPanelState extends BasePanelState<StudioRulesPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final rules = ref.watch(studioRulesControllerProvider);

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
                  Expanded(child: Text('Stüdyo kuralları', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                  Material(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      onTap: () => ref.read(panelStackControllerProvider.notifier).push(const EditStudioRulesPanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text('Düzenle', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onSurfaceVariant)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  Text('Son güncelleme ${rules.lastUpdatedLabel}', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Text(rules.text, style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15, height: 1.65)),
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
