import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/admin_trainer_detail_controller.dart';
import '../../controller/admin_trainers_controller.dart';
import '../../controller/trainer_activity_breakdown_controller.dart';
import '../../domain/admin_trainer_detail_stats.dart';
import '../../domain/admin_trainer_summary.dart';
import '../../domain/trainer_activity_breakdown.dart';
import '../../service/trainer_registration_service.dart';
import 'admin_trainer_management_panel.dart' show showTrainerFormSheet;

/// Admin 4 · Antrenör Detayı — [AdminTrainerManagementPanel]'deki listeden
/// bir antrenöre dokununca açılır, tüm zamanlı ve bu ayki seans
/// istatistiklerini gösterir.
class AdminTrainerDetailPanel extends BasePanel {
  const AdminTrainerDetailPanel({required this.trainer, super.key});

  final AdminTrainerSummary trainer;

  @override
  ConsumerState<AdminTrainerDetailPanel> createState() =>
      _AdminTrainerDetailPanelState();
}

class _AdminTrainerDetailPanelState
    extends BasePanelState<AdminTrainerDetailPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    // Liste (`AdminTrainersController`) Firestore'u canlı izliyor —
    // `widget.trainer` sadece bu panele push edildiği andaki durağan bir
    // kopya, `Düzenle` sonrası güncel kalması için burada listeden aranıyor
    // (bulunamazsa, ör. mock/salon-yok durumunda, orijinal kopyaya düşülür).
    final trainer = ref
        .watch(adminTrainersControllerProvider)
        .firstWhere(
          (t) => t.id == widget.trainer.id,
          orElse: () => widget.trainer,
        );
    final stats =
        ref.watch(adminTrainerDetailStatsProvider(trainer.id)).valueOrNull ??
        AdminTrainerDetailStats.empty;
    final activity = ref.watch(trainerActivityBreakdownProvider(trainer.id));
    final memberCountText = ref
        .watch(rcTextProvider(RemoteConfigKeys.trainersMemberCountSuffix))
        .replaceAll('{count}', '${trainer.memberCount}');

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
                        rcTextProvider(RemoteConfigKeys.trainersDetailTitle),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Material(
                    color: colors.surfaceRaised,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      onTap: () =>
                          showTrainerFormSheet(context, existing: trainer),
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
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            trainer.initials,
                            style: typography.headingSmall.copyWith(
                              color: colors.onPrimaryContainer,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trainer.name,
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                trainer.phone.isEmpty ? '—' : trainer.phone,
                                style: typography.bodyMedium.copyWith(
                                  color: colors.onSurfaceMuted,
                                ),
                              ),
                              if (trainer.specialties.isNotEmpty)
                                Text(
                                  trainer.specialties.join(', '),
                                  style: typography.bodyMedium.copyWith(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              Text(
                                memberCountText,
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
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersDetailAllTimeSection,
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
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.membersDetailTotalLabel,
                              ),
                            ),
                            value: '${stats.totalSessions}',
                            valueColor: colors.onSurface,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.trainersHomeCompletedLabel,
                              ),
                            ),
                            value: '${stats.completedSessions}',
                            valueColor: colors.success,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.trainersDetailPlannedLabel,
                              ),
                            ),
                            value: '${stats.plannedSessions}',
                            valueColor: colors.primary,
                          ),
                        ),
                        Expanded(
                          child: _StatTile(
                            label: ref.watch(
                              rcTextProvider(RemoteConfigKeys.commonIptalLabel),
                            ),
                            value: '${stats.cancelledSessions}',
                            valueColor: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersDetailThisMonthSection,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ActivityBreakdownCard(
                    activity: activity,
                    counts: (b) => b.monthly,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.trainersDetailThisWeekSection,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ActivityBreakdownCard(
                    activity: activity,
                    counts: (b) => b.weekly,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: ref.watch(
                      rcTextProvider(RemoteConfigKeys.trainersDeleteButton),
                    ),
                    variant: AppButtonVariant.secondary,
                    onPressed: () => _showDeleteSheet(trainer.id, trainer.name),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Silme geri alınamaz olduğu için önce onay alınır. Onay metni, verinin
  /// KALDIĞINI açıkça söylüyor — admin "geçmişi de siliyorum" sanmasın.
  ///
  /// `admin_session_management_panel.dart`'taki iptal akışıyla aynı desen:
  /// sheet, yazma TAMAMLANANA kadar açık kalır (`StatefulBuilder`), hata
  /// olursa içeride gösterilir — geri alınamaz bir aksiyonda "kapandı, demek
  /// ki oldu" yanılgısını önlemek için.
  void _showDeleteSheet(String trainerId, String trainerName) {
    final colors = context.appColors;
    final typography = context.appTypography;
    var isDeleting = false;
    String? deleteError;

    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setLocalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.read(
                      rcTextProvider(
                        RemoteConfigKeys.trainersDeleteConfirmTitle,
                      ),
                    ),
                    style: typography.headingLarge.copyWith(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ref
                        .read(
                          rcTextProvider(
                            RemoteConfigKeys.trainersDeleteConfirmBody,
                          ),
                        )
                        .replaceAll('{name}', trainerName),
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                    ),
                  ),
                  if (deleteError != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      deleteError!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    label: isDeleting
                        ? ref.read(
                            rcTextProvider(RemoteConfigKeys.membersSavingLabel),
                          )
                        : ref.read(
                            rcTextProvider(
                              RemoteConfigKeys.trainersDeleteConfirmCta,
                            ),
                          ),
                    variant: AppButtonVariant.secondary,
                    onPressed: isDeleting
                        ? null
                        : () async {
                            setLocalState(() {
                              isDeleting = true;
                              deleteError = null;
                            });
                            try {
                              await ref
                                  .read(trainerRegistrationServiceProvider)
                                  .deactivateTrainer(trainerId);
                            } catch (_) {
                              setLocalState(() {
                                isDeleting = false;
                                deleteError = ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.trainersDeleteError,
                                  ),
                                );
                              });
                              return;
                            }
                            if (!sheetContext.mounted) return;
                            Navigator.of(sheetContext).pop();
                            // Antrenör artık `AdminTrainersController`
                            // listesinde yok — bu panel geçersiz bir kayda
                            // bakıyor, listeye dönülür.
                            if (mounted) {
                              ref
                                  .read(panelStackControllerProvider.notifier)
                                  .pop();
                            }
                          },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: ref.read(
                      rcTextProvider(RemoteConfigKeys.commonVazgec),
                    ),
                    variant: AppButtonVariant.text,
                    onPressed: isDeleting
                        ? null
                        : () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// "BU AY"/"BU HAFTA" kartı — [counts] ile aynı [activity] snapshot'ından
/// aylık ya da haftalık kırılımı seçip Tamamlanan/Planlanan alt
/// başlıklarıyla (birebir seans + düet ders) render eder. Grup dersleri şu
/// an bir antrenöre atanmadığından (bkz. `TrainerActivityCounts` yorumu)
/// burada gösterilmiyor.
class _ActivityBreakdownCard extends ConsumerWidget {
  const _ActivityBreakdownCard({required this.activity, required this.counts});

  final AsyncValue<TrainerActivityBreakdown> activity;
  final TrainerActivityCounts Function(TrainerActivityBreakdown) counts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: activity.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, _) => Text(
          ref.watch(
            rcTextProvider(RemoteConfigKeys.trainersDetailMonthLoadError),
          ),
          style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
        ),
        data: (breakdown) {
          final c = counts(breakdown);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.trainersHomeCompletedLabel),
                ),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ActivityRow(
                label: ref.watch(
                  rcTextProvider(RemoteConfigKeys.sessionsCreateKindIndividual),
                ),
                value: c.individualCompleted,
              ),
              _ActivityRow(
                label: ref.watch(
                  rcTextProvider(RemoteConfigKeys.sessionsCreateKindDuet),
                ),
                value: c.duetCompleted,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ref.watch(
                  rcTextProvider(RemoteConfigKeys.trainersDetailPlannedLabel),
                ),
                style: typography.caption.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              _ActivityRow(
                label: ref.watch(
                  rcTextProvider(RemoteConfigKeys.sessionsCreateKindIndividual),
                ),
                value: c.individualPlanned,
              ),
              _ActivityRow(
                label: ref.watch(
                  rcTextProvider(RemoteConfigKeys.sessionsCreateKindDuet),
                ),
                value: c.duetPlanned,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: typography.bodyLarge.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            '$value',
            style: typography.headingSmall.copyWith(
              color: colors.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Column(
      children: [
        Text(
          value,
          style: typography.dataLarge.copyWith(color: valueColor, fontSize: 20),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: typography.caption.copyWith(color: colors.onSurfaceMuted),
        ),
      ],
    );
  }
}
