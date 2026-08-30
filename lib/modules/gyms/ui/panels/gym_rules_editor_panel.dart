import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
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
  final _editorFocusNode = FocusNode();
  late final int _maxChars;
  bool _isSaving = false;
  String? _errorMessage;

  // Quill'in dokümanı her zaman sondaki bir '\n' ile bitirdiğinden, gerçek
  // karakter sayımında bu sondaki satır sonu düşülüyor — kullanıcı tek bir
  // karakter bile yazmasa sayaç hâlâ 0 göstermeli.
  int get _charCount {
    final text = _controller.document.toPlainText();
    return text.endsWith('\n') ? text.length - 1 : text.length;
  }

  bool get _isOverLimit => _charCount > _maxChars;

  @override
  void initState() {
    super.initState();
    // RC henüz Firebase ile fetch edilmemişse (ör. widget test ortamı)
    // getInt çağrısı fırlatabilir — bu durumda mock/varsayılan üst sınırla
    // devam edilir (bkz. CreateGroupSessionController'daki aynı desen).
    try {
      _maxChars = ref.read(remoteConfigServiceProvider).gymRulesMaxChars;
    } catch (_) {
      _maxChars = 6000;
    }
    _controller = QuillController(
      document: Document.fromJson(ref.read(gymRulesControllerProvider).delta),
      selection: const TextSelection.collapsed(offset: 0),
    );
    // Karakter sayacının canlı güncellenmesi (ve limit aşımında Kaydet
    // butonunun devre dışı kalması) için doküman değişikliklerini dinliyor.
    _controller.addListener(() => setState(() {}));
  }

  /// Önceki sürüm yazma işlemini `await` etmeden paneli kapatıyordu — kayıt
  /// arka planda başarısız olsa bile kullanıcı "kaydedildi" sanıyordu. Artık
  /// yazma tamamlanana kadar bekleniyor, hata olursa panelde kalınıp
  /// gösteriliyor.
  Future<void> _save() async {
    if (_isOverLimit) {
      setState(
        () => _errorMessage = ref
            .read(
              rcTextProvider(RemoteConfigKeys.gymsRulesEditorMaxLengthError),
            )
            .replaceAll('{max}', '$_maxChars'),
      );
      return;
    }
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
          () => _errorMessage = ref.read(
            rcTextProvider(RemoteConfigKeys.gymsRulesEditorSaveFailedError),
          ),
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
                      ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.gymsEditStudioRulesTitle,
                        ),
                      ),
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
                      ref.watch(rcTextProvider(RemoteConfigKeys.commonVazgec)),
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
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.gymsRulesEditorToolbarHint),
                ),
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
              clipBehavior: Clip.antiAlias,
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
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: (_) => _editorFocusNode.requestFocus(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: QuillEditor.basic(
                      controller: _controller,
                      focusNode: _editorFocusNode,
                      config: QuillEditorConfig(
                        expands: true,
                        padding: EdgeInsets.zero,
                        // Panel'in üstündeki global "dışarı tıklayınca
                        // klavyeyi kapat" GestureDetector'ı (bkz.
                        // panel_stack_view.dart) tap-up anında unfocus()
                        // çağırıyor; Quill kendi odağını daha geç istediği
                        // için buna yenik düşüyordu — odak burada tap-down
                        // anında elle isteniyor (standart TextField'ın aynı
                        // yarışı kazandığı yöntemle aynı).
                        contextMenuBuilder: (context, rawEditorState) {
                          final selection =
                              rawEditorState.textEditingValue.selection;
                          final buttonItems =
                              EditableText.getEditableButtonItems(
                                clipboardStatus: ClipboardStatus.pasteable,
                                onCopy: () => rawEditorState.copySelection(
                                  SelectionChangedCause.toolbar,
                                ),
                                onCut: selection.isCollapsed
                                    ? null
                                    : () => rawEditorState.cutSelection(
                                        SelectionChangedCause.toolbar,
                                      ),
                                onPaste: () => rawEditorState.pasteText(
                                  SelectionChangedCause.toolbar,
                                ),
                                onSelectAll: () => rawEditorState.selectAll(
                                  SelectionChangedCause.toolbar,
                                ),
                                onLookUp: null,
                                onSearchWeb: null,
                                onShare: null,
                                onLiveTextInput: null,
                              );
                          return TextFieldTapRegion(
                            child: AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: rawEditorState.contextMenuAnchors,
                              buttonItems: buttonItems,
                            ),
                          );
                        },
                      ),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      ref
                          .watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsRulesEditorCharCountTemplate,
                            ),
                          )
                          .replaceAll('{count}', '$_charCount')
                          .replaceAll('{max}', '$_maxChars'),
                      style: typography.caption.copyWith(
                        color: _isOverLimit
                            ? colors.error
                            : colors.onSurfaceMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                    label: _isSaving
                        ? ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsGymInfoSavingLabel,
                            ),
                          )
                        : ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonKaydet),
                          ),
                    onPressed: _isSaving || _isOverLimit ? null : _save,
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
    _editorFocusNode.dispose();
    super.dispose();
  }
}
