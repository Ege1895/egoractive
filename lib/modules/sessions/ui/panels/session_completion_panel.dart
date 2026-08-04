import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';

enum _CompletionAnswer { pending, done, absent }

/// Antrenör 6 · Ders Tamamlama Onayı — tek dokunuşla "tamamlandı mı?" akışı.
class SessionCompletionPanel extends BasePanel {
  const SessionCompletionPanel({
    required this.time,
    required this.memberInitials,
    required this.memberName,
    required this.meta,
    required this.remainingBefore,
    super.key,
  });

  final String time;
  final String memberInitials;
  final String memberName;
  final String meta;
  final int remainingBefore;

  @override
  ConsumerState<SessionCompletionPanel> createState() => _SessionCompletionPanelState();
}

class _SessionCompletionPanelState extends BasePanelState<SessionCompletionPanel> {
  _CompletionAnswer _answer = _CompletionAnswer.pending;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final remainingAfter = (widget.remainingBefore - 1).clamp(0, widget.remainingBefore);

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
                  Text('Seans onayı', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.time} ${widget.memberName} seansını tamamladınız mı?',
                            style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 26),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.memberInitials,
                                    style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.meta, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                                      Text(
                                        'Onaylarsanız kalan dersi ${widget.remainingBefore}\'dan $remainingAfter\'e düşer',
                                        style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_answer == _CompletionAnswer.pending) ...[
                      AppButton(label: 'Tamamlandı', onPressed: () => setState(() => _answer = _CompletionAnswer.done)),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Üye gelmedi',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => setState(() => _answer = _CompletionAnswer.absent),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Onayı 24 saat içinde verebilirsiniz, sonrasında yönetici onayı gerekir.',
                        textAlign: TextAlign.center,
                        style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: _answer == _CompletionAnswer.done ? colors.successContainer : colors.warningContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                          border: Border.all(
                            color: (_answer == _CompletionAnswer.done ? colors.success : colors.warning).withValues(alpha: 0.32),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: _answer == _CompletionAnswer.done ? colors.success : colors.warning,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _answer == _CompletionAnswer.done ? '✓' : '–',
                                style: typography.headingSmall.copyWith(color: colors.background, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _answer == _CompletionAnswer.done ? 'Ders tamamlandı işaretlendi' : 'Üye gelmedi olarak işaretlendi',
                                    style: typography.headingSmall.copyWith(
                                      color: _answer == _CompletionAnswer.done ? colors.onSuccessContainer : colors.onWarningContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _answer == _CompletionAnswer.done
                                        ? '${widget.memberName}\'ın kalan dersi $remainingAfter\'e düştü.'
                                        : '${widget.memberName}\'ın kalan dersi düşmedi, yöneticiye iletildi.',
                                    style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppButton(
                        label: 'Geri al',
                        variant: AppButtonVariant.secondary,
                        onPressed: () => setState(() => _answer = _CompletionAnswer.pending),
                      ),
                    ],
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
