import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/gym_rules_controller.dart';

/// Admin · Kuralları Düzenle — zengin metin (kalın/italik/liste vb.)
/// `flutter_quill` ile düzenlenir; emoji, cihazın kendi emoji klavyesiyle
/// eklenir (özel bir emoji seçici gerekmiyor — normal metin girişi gibi
/// çalışır). Kaydedince Quill Delta JSON `gyms/{gymId}.rulesContent`'e yazılır.
class GymRulesEditorPanel extends BasePanel {
  const GymRulesEditorPanel({super.key});

  @override
  ConsumerState<GymRulesEditorPanel> createState() =>
      _GymRulesEditorPanelState();
}

class _GymRulesEditorPanelState extends BasePanelState<GymRulesEditorPanel> {
  late final QuillController _controller;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document.fromJson(ref.read(gymRulesControllerProvider).delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  /// Önceki sürüm yazma işlemini `await` etmeden paneli kapatıyordu — kayıt
  /// arka planda başarısız olsa bile kullanıcı "kaydedildi" sanıyordu. Artık
  /// yazma tamamlanana kadar bekleniyor, hata olursa panelde kalınıp
  /// gösteriliyor.
  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(gymRulesControllerProvider.notifier)
          .saveRules(_controller.document.toDelta().toJson());
      if (mounted) ref.read(panelStackControllerProvider.notifier).pop();
    } catch (_) {
      if (mounted) {
        setState(
          () => _errorMessage =
              'Kurallar kaydedilemedi, bağlantını kontrol edip tekrar dene.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

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
                  Expanded(
                    child: Text(
                      'Kuralları düzenle',
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                    child: Text(
                      'Vazgeç',
                      style: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 15,
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
                0,
              ),
              child: Text(
                'Kalın/italik gibi biçimlendirme için araç çubuğunu, emoji için klavyenizin emoji tuşunu kullanabilirsiniz.',
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenEdge,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                border: Border.all(color: colors.outline),
              ),
              child: QuillSimpleToolbar(
                controller: _controller,
                config: const QuillSimpleToolbarConfig(
                  showFontFamily: false,
                  showFontSize: false,
                  showSmallButton: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: false,
                  showAlignmentButtons: false,
                  showHeaderStyle: false,
                  showListCheck: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showLink: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showDirection: false,
                  showStrikeThrough: false,
                  showInlineCode: false,
                  multiRowsDisplay: false,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.screenEdge),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: QuillEditor.basic(
                    controller: _controller,
                    config: const QuillEditorConfig(
                      expands: true,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                0,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _isSaving ? 'Kaydediliyor…' : 'Kaydet',
                    onPressed: _isSaving ? null : _save,
                  ),
                ],
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
