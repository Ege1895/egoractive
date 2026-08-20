import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/gym_rules_controller.dart';
import 'gym_rules_editor_panel.dart';

/// Herkes · Stüdyo Kuralları (görüntüleme) — salt okunur Quill render.
/// `showEditButton: true` sadece admin akışından (Ayarlar) açıldığında
/// verilir; üye/antrenör profilinden açıldığında düzenle butonu yok.
class GymRulesViewPanel extends BasePanel {
  const GymRulesViewPanel({super.key, this.showEditButton = false});

  final bool showEditButton;

  @override
  ConsumerState<GymRulesViewPanel> createState() => _GymRulesViewPanelState();
}

class _GymRulesViewPanelState extends BasePanelState<GymRulesViewPanel> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromJson(ref.read(gymRulesControllerProvider).delta),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final rules = ref.watch(gymRulesControllerProvider);

    ref.listen(gymRulesControllerProvider, (previous, next) {
      if (previous?.delta != next.delta) {
        _controller.document = Document.fromJson(next.delta);
      }
    });

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
                  Expanded(
                    child: Text(
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.commonStudyoKurallariNav,
                        ),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (widget.showEditButton)
                    Material(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        onTap: () => ref
                            .read(panelStackControllerProvider.notifier)
                            .push(const GymRulesEditorPanel()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          constraints: const BoxConstraints(minHeight: 40),
                          alignment: Alignment.center,
                          child: Text(
                            ref.watch(
                              rcTextProvider(RemoteConfigKeys.commonDuzenle),
                            ),
                            style: typography.headingSmall.copyWith(
                              fontSize: 14,
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (rules.lastUpdatedLabel != null) ...[
                      Text(
                        ref
                            .watch(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .gymsRulesViewLastUpdatedTemplate,
                              ),
                            )
                            .replaceAll('{date}', rules.lastUpdatedLabel ?? ''),
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          border: Border.all(color: colors.outline),
                        ),
                        // readOnly:true Quill'de hâlâ dokununca imleç/odak
                        // gösterip düzenlenebilir bir alanmış izlenimi
                        // yaratıyor — salt-okunur görüntüleme için tamamen
                        // etkileşimsiz olması gerekiyor.
                        child: IgnorePointer(
                          child: QuillEditor.basic(
                            controller: _controller,
                            config: const QuillEditorConfig(
                              expands: true,
                              padding: EdgeInsets.zero,
                              showCursor: false,
                            ),
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
