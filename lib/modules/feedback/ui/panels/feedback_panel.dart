import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../controller/feedback_controller.dart';

const _ratingLabels = [
  'Puan vermek için dokun',
  'Hiç iyi geçmedi',
  'Beklediğim gibi değildi',
  'Fena değildi',
  'İyiydi',
  'Harikaydı',
];
const _maxCommentLength = 500;

/// Üye 7 · Geri Bildirim.
class FeedbackPanel extends BasePanel {
  const FeedbackPanel({super.key});

  @override
  ConsumerState<FeedbackPanel> createState() => _FeedbackPanelState();
}

class _FeedbackPanelState extends BasePanelState<FeedbackPanel> {
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(feedbackControllerProvider);
    final controller = ref.read(feedbackControllerProvider.notifier);

    ref.listen(feedbackControllerProvider, (previous, next) {
      if (!previous!.isSubmitted && next.isSubmitted) {
        ref.read(panelStackControllerProvider.notifier).pop();
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
                  Text(
                    'Geri bildirim',
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
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
                    Text(
                      '30 Temmuz dersin nasıl geçti?',
                      style: typography.headingMedium.copyWith(
                        color: colors.onSurface,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Berk Aydın ile birebir · Yalnızca stüdyo yönetimi görür, antrenörüne isimsiz iletilir.',
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 1; i <= 5; i++)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  child: _StarButton(
                                    filled: i <= state.rating,
                                    onTap: () => controller.setRating(i),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _ratingLabels[state.rating],
                            style: typography.headingSmall.copyWith(
                              fontSize: 16,
                              color: state.rating == 0
                                  ? colors.onSurfaceMuted
                                  : colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'YORUMUN (İSTEĞE BAĞLI)',
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      constraints: const BoxConstraints(minHeight: 132),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusCard,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _commentController,
                            maxLines: 4,
                            maxLength: _maxCommentLength,
                            onChanged: controller.setComment,
                            style: typography.bodyLarge.copyWith(
                              color: colors.onSurfaceVariant,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                              hintText:
                                  'Isınma bölümü bu hafta çok iyiydi, esneme için 5 dakika daha olsa harika olur.',
                              hintStyle: typography.bodyLarge.copyWith(
                                color: colors.onSurfaceMuted,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            '${_commentController.text.length} / $_maxCommentLength',
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: colors.background,
                border: Border(top: BorderSide(color: colors.outline)),
              ),
              child: Column(
                children: [
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  Material(
                    color: state.rating == 0
                        ? colors.surfaceRaised
                        : colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      onTap: state.rating == 0 || state.isSubmitting
                          ? null
                          : controller.submit,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          minHeight: AppSpacing.primaryActionHeight,
                        ),
                        alignment: Alignment.center,
                        child: state.isSubmitting
                            ? const AppLoadingIndicator(size: 22)
                            : Text(
                                'Gönder',
                                style: typography.headingSmall.copyWith(
                                  fontSize: 17,
                                  color: state.rating == 0
                                      ? colors.onSurfaceMuted
                                      : colors.onPrimary,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    state.rating == 0
                        ? 'Göndermek için yıldız ver'
                        : 'Antrenörüne isimsiz iletilir',
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
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
    _commentController.dispose();
    super.dispose();
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({required this.filled, required this.onTap});

  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: filled ? colors.primaryContainer : colors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
          border: Border.all(
            color: filled ? colors.primary : colors.outlineStrong,
          ),
        ),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: 0.785398, // 45°
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: filled
                  ? colors.primary
                  : colors.onSurfaceMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}
