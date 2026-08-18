import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../trainers/controller/admin_trainers_controller.dart';
import '../../../trainers/domain/admin_trainer_summary.dart';
import 'trainer_permissions_edit_panel.dart';

/// Admin 18a · Yetki Ayarları — önce bir ya da birden fazla antrenör
/// seçilir, "Yetkilendir" ile o antrenör(ler)e özel ayar ekranı açılır.
/// O ekrandaki "Kaydet" buraya geri döner.
class AdminPermissionsPanel extends BasePanel {
  const AdminPermissionsPanel({super.key});

  @override
  ConsumerState<AdminPermissionsPanel> createState() =>
      _AdminPermissionsPanelState();
}

class _AdminPermissionsPanelState
    extends BasePanelState<AdminPermissionsPanel> {
  final Set<String> _selectedIds = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final trainers = ref.watch(adminTrainersControllerProvider);
    final selectedTrainers = trainers
        .where((t) => _selectedIds.contains(t.id))
        .toList();

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
                    'Yetki ayarları',
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Text(
                    'Hangi antrenöre yetkilendirme yapmak istiyorsun?',
                    style: typography.headingSmall.copyWith(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Bir ya da birden fazla antrenör seçebilirsin; aynı ayarlar hepsine uygulanır.',
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                    onTap: () => _showTrainerPicker(context),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              selectedTrainers.isEmpty
                                  ? '?'
                                  : '${selectedTrainers.length}',
                              style: typography.headingSmall.copyWith(
                                color: colors.onPrimaryContainer,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              selectedTrainers.isEmpty
                                  ? 'Antrenör seç'
                                  : selectedTrainers
                                        .map((t) => t.name)
                                        .join(', '),
                              overflow: TextOverflow.ellipsis,
                              style: typography.headingSmall.copyWith(
                                color: colors.onSurface,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            'Değiştir',
                            style: typography.headingSmall.copyWith(
                              color: colors.onPrimaryContainer,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                AppSpacing.lg,
              ),
              child: AppButton(
                label: 'Yetkilendir',
                onPressed: selectedTrainers.isEmpty
                    ? null
                    : () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(
                            TrainerPermissionsEditPanel(
                              trainers: selectedTrainers,
                            ),
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTrainerPicker(BuildContext context) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Antrenör seç',
                  style: context.appTypography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Flexible(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final trainers = ref.watch(
                        adminTrainersControllerProvider,
                      );
                      if (trainers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            'Henüz antrenör yok.',
                            style: context.appTypography.bodyMedium.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        );
                      }
                      return StatefulBuilder(
                        builder: (context, setSheetState) {
                          return ListView(
                            shrinkWrap: true,
                            children: [
                              for (final trainer in trainers)
                                _TrainerOption(
                                  trainer: trainer,
                                  selected: _selectedIds.contains(trainer.id),
                                  onTap: () {
                                    setSheetState(() {
                                      setState(() {
                                        if (_selectedIds.contains(trainer.id)) {
                                          _selectedIds.remove(trainer.id);
                                        } else {
                                          _selectedIds.add(trainer.id);
                                        }
                                      });
                                    });
                                  },
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Bitti',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TrainerOption extends StatelessWidget {
  const _TrainerOption({
    required this.trainer,
    required this.selected,
    required this.onTap,
  });

  final AdminTrainerSummary trainer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                trainer.initials,
                style: typography.headingSmall.copyWith(
                  color: colors.onPrimaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                trainer.name,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? colors.primary : colors.outlineStrong,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Icon(Icons.check, size: 14, color: colors.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
