import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../service/session_completion_service.dart';

enum _CompletionAnswer { pending, done, absent }

/// Antrenör 6 · Ders Tamamlama Onayı — tek dokunuşla "tamamlandı mı?" akışı.
///
/// F3-5 — `sessionId`/`memberId` verilirse "Tamamlandı"/"Üye gelmedi"
/// gerçek Firestore'a yazar (kalan seans sayısı transaction içinde
/// düşülür). Verilmezse (henüz gerçek veriye bağlanmamış eski çağrı
/// noktaları için) sadece yerel önizleme gösterir, hiçbir yere yazmaz.
class SessionCompletionPanel extends BasePanel {
  const SessionCompletionPanel({
    required this.time,
    required this.memberInitials,
    required this.memberName,
    required this.meta,
    required this.remainingBefore,
    this.sessionId,
    this.memberId,
    super.key,
  });

  final String time;
  final String memberInitials;
  final String memberName;
  final String meta;
  final int remainingBefore;
  final String? sessionId;
  final String? memberId;

  @override
  ConsumerState<SessionCompletionPanel> createState() =>
      _SessionCompletionPanelState();
}

class _SessionCompletionPanelState
    extends BasePanelState<SessionCompletionPanel> {
  _CompletionAnswer _answer = _CompletionAnswer.pending;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _markCompleted() async {
    final sessionId = widget.sessionId;
    final memberId = widget.memberId;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      if (sessionId != null && memberId != null) {
        await ref
            .read(sessionCompletionServiceProvider)
            .markCompleted(sessionId: sessionId, memberId: memberId);
      }
      if (mounted) setState(() => _answer = _CompletionAnswer.done);
    } catch (error) {
      // TEMP TEŞHİS — kaldırılacak: gerçek Firestore hatasını (ör.
      // permission-denied kodu/mesajı) ekranda göstererek teşhis ediyoruz —
      // kullanıcı konsola erişemeden (canlı build) hatayı bildirebilsin diye.
      debugPrint('SessionCompletionPanel._markCompleted hata: $error');
      if (mounted) {
        setState(
          () => _errorMessage =
              '${ref.read(rcTextProvider(RemoteConfigKeys.sessionsCompletionConfirmError))}\n[DEBUG] $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _markAbsent() async {
    final sessionId = widget.sessionId;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      if (sessionId != null) {
        await ref.read(sessionCompletionServiceProvider).markAbsent(sessionId);
      }
      if (mounted) setState(() => _answer = _CompletionAnswer.absent);
    } catch (error) {
      debugPrint('SessionCompletionPanel._markAbsent hata: $error');
      if (mounted) {
        setState(
          () => _errorMessage =
              '${ref.read(rcTextProvider(RemoteConfigKeys.sessionsCompletionConfirmError))}\n[DEBUG] $error',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final remainingAfter = (widget.remainingBefore - 1).clamp(
      0,
      widget.remainingBefore,
    );

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
                    ref.watch(
                      rcTextProvider(RemoteConfigKeys.sessionsCompletionTitle),
                    ),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys.sessionsCompletionQuestion,
                                  ),
                                )
                                .replaceAll('{time}', widget.time)
                                .replaceAll('{name}', widget.memberName),
                            style: typography.headingMedium.copyWith(
                              color: colors.onSurface,
                              fontSize: 26,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInner,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    widget.memberInitials,
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onPrimaryContainer,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.meta,
                                        style: typography.headingSmall.copyWith(
                                          color: colors.onSurface,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        ref
                                            .watch(
                                              rcTextProvider(
                                                RemoteConfigKeys
                                                    .sessionsCompletionSummary,
                                              ),
                                            )
                                            .replaceAll(
                                              '{before}',
                                              '${widget.remainingBefore}',
                                            )
                                            .replaceAll(
                                              '{after}',
                                              '$remainingAfter',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_answer == _CompletionAnswer.pending) ...[
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: typography.bodyMedium.copyWith(
                            color: colors.error,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],
                      AppButton(
                        label: _isSubmitting
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.gymsGymSetupSubmittingLabel,
                                ),
                              )
                            : ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.commonTamamlandi,
                                ),
                              ),
                        onPressed: _isSubmitting ? null : _markCompleted,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: ref.watch(
                          rcTextProvider(
                            RemoteConfigKeys
                                .sessionsCompletionMemberNoShowOption,
                          ),
                        ),
                        variant: AppButtonVariant.secondary,
                        onPressed: _isSubmitting ? null : _markAbsent,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        ref.watch(
                          rcTextProvider(
                            RemoteConfigKeys.sessionsCompletionTimeLimitNote,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        style: typography.caption.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: _answer == _CompletionAnswer.done
                              ? colors.successContainer
                              : colors.warningContainer,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusCard,
                          ),
                          border: Border.all(
                            color:
                                (_answer == _CompletionAnswer.done
                                        ? colors.success
                                        : colors.warning)
                                    .withValues(alpha: 0.32),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: _answer == _CompletionAnswer.done
                                    ? colors.success
                                    : colors.warning,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _answer == _CompletionAnswer.done ? '✓' : '–',
                                style: typography.headingSmall.copyWith(
                                  color: colors.background,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _answer == _CompletionAnswer.done
                                        ? ref.watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .sessionsCompletionDoneMarked,
                                            ),
                                          )
                                        : ref.watch(
                                            rcTextProvider(
                                              RemoteConfigKeys
                                                  .sessionsCompletionAbsentMarked,
                                            ),
                                          ),
                                    style: typography.headingSmall.copyWith(
                                      color: _answer == _CompletionAnswer.done
                                          ? colors.onSuccessContainer
                                          : colors.onWarningContainer,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    _answer == _CompletionAnswer.done
                                        ? ref
                                              .watch(
                                                rcTextProvider(
                                                  RemoteConfigKeys
                                                      .sessionsCompletionDoneSummary,
                                                ),
                                              )
                                              .replaceAll(
                                                '{name}',
                                                widget.memberName,
                                              )
                                              .replaceAll(
                                                '{after}',
                                                '$remainingAfter',
                                              )
                                        : ref
                                              .watch(
                                                rcTextProvider(
                                                  RemoteConfigKeys
                                                      .sessionsCompletionAbsentSummary,
                                                ),
                                              )
                                              .replaceAll(
                                                '{name}',
                                                widget.memberName,
                                              ),
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (widget.sessionId != null) ...[
                        // Onay zaten Firestore'a yazıldı (remainingSessions
                        // transaction içinde düşürüldü) — "Geri al" bu
                        // yazımı geri almadan yalnızca local state'i
                        // sıfırlarsa, kullanıcı tekrar onaylayınca kalan
                        // ders sayısı iki kez düşer. Gerçek bir compensating
                        // write olmadığı için yeniden gönderim tamamen
                        // engelleniyor.
                        AppButton(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.gymsPermissionsDoneButton,
                            ),
                          ),
                          variant: AppButtonVariant.secondary,
                          onPressed: () => ref
                              .read(panelStackControllerProvider.notifier)
                              .pop(),
                        ),
                      ] else
                        AppButton(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.sessionsCompletionUndoButton,
                            ),
                          ),
                          variant: AppButtonVariant.secondary,
                          onPressed: () => setState(
                            () => _answer = _CompletionAnswer.pending,
                          ),
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
