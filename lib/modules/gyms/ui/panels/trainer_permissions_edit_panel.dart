import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../trainers/domain/admin_trainer_summary.dart';
import '../../controller/trainer_permissions_controller.dart';
import '../../domain/admin_permissions.dart';

/// Admin 18b · seçilen bir ya da birden fazla antrenör için yetki
/// ayarlarını düzenler. [AdminPermissionsPanel]'deki antrenör seçim
/// adımından sonra açılır; "Kaydet" bu panele değil, seçim adımına döner.
class TrainerPermissionsEditPanel extends BasePanel {
  const TrainerPermissionsEditPanel({required this.trainers, super.key});

  final List<AdminTrainerSummary> trainers;

  @override
  ConsumerState<TrainerPermissionsEditPanel> createState() =>
      _TrainerPermissionsEditPanelState();
}

class _TrainerPermissionsEditPanelState
    extends BasePanelState<TrainerPermissionsEditPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(trainerPermissionsControllerProvider.notifier)
          .loadFrom(widget.trainers.first.id);
    });
  }

  List<String> get _trainerIds => widget.trainers.map((t) => t.id).toList();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final permissions = ref.watch(trainerPermissionsControllerProvider);
    final controller = ref.read(trainerPermissionsControllerProvider.notifier);
    final trainerNames = widget.trainers.map((t) => t.name).join(', ');

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
                          RemoteConfigKeys.gymsPermissionsAuthorizeButton,
                        ),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.sm,
                AppSpacing.screenEdge,
                0,
              ),
              child: Text(
                trainerNames,
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceMuted,
                ),
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
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
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsReminderQuestion,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsReminderNote,
                            ),
                          ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            for (final delay in TrainerReminderDelay.values)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        delay ==
                                            TrainerReminderDelay.values.last
                                        ? 0
                                        : AppSpacing.sm,
                                  ),
                                  child: _DelayChip(
                                    label: delay.label,
                                    selected:
                                        permissions.trainerReminderDelay ==
                                        delay,
                                    onTap: () => _handlePermissionAction(
                                      context,
                                      () => controller.setReminderDelay(
                                        delay,
                                        _trainerIds,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        _PermissionToggle(
                          title: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsOnlineBookingTitle,
                            ),
                          ),
                          note: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsOnlineBookingNote,
                            ),
                          ),
                          value: permissions.onlineBookingEnabled,
                          onTap: () => _handlePermissionAction(
                            context,
                            () => controller.toggleOnlineBooking(_trainerIds),
                          ),
                          showDivider: true,
                        ),
                        _PermissionToggle(
                          title: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsAllowAfterExpiryTitle,
                            ),
                          ),
                          note: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsAllowAfterExpiryNote,
                            ),
                          ),
                          value: permissions.allowSessionsAfterPackageExpiry,
                          onTap: () => _handlePermissionAction(
                            context,
                            () => controller.toggleAllowSessionsAfterExpiry(
                              _trainerIds,
                            ),
                          ),
                          showDivider: true,
                        ),
                        _PermissionToggle(
                          title: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsMemberCancelTitle,
                            ),
                          ),
                          note: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .gymsTrainerPermissionsMemberCancelNote,
                            ),
                          ),
                          value: permissions.memberCanCancelSession,
                          onTap: () => _handlePermissionAction(
                            context,
                            () => controller.toggleMemberCanCancel(_trainerIds),
                          ),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.gymsTrainerPermissionsAutoSaveNote,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
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
                label: ref.watch(rcTextProvider(RemoteConfigKeys.commonKaydet)),
                onPressed: () =>
                    ref.read(panelStackControllerProvider.notifier).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _handlePermissionAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProviderScope.containerOf(context).read(
              rcTextProvider(
                RemoteConfigKeys.gymsTrainerPermissionsSaveFailedError,
              ),
            ),
          ),
        ),
      );
    }
  }
}

class _DelayChip extends StatelessWidget {
  const _DelayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionToggle extends StatelessWidget {
  const _PermissionToggle({
    required this.title,
    required this.note,
    required this.value,
    required this.onTap,
    required this.showDivider,
  });

  final String title;
  final String note;
  final bool value;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
                Text(
                  note,
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 52,
              height: 32,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? colors.primary : colors.surfaceRaised,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: colors.onSurface,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
