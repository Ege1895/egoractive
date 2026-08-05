import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/admin_permissions_controller.dart';
import '../../domain/admin_permissions.dart';

/// Admin 18 · Yetki Ayarları — hatırlatma süresi + üç toggle.
class AdminPermissionsPanel extends BasePanel {
  const AdminPermissionsPanel({super.key});

  @override
  ConsumerState<AdminPermissionsPanel> createState() => _AdminPermissionsPanelState();
}

class _AdminPermissionsPanelState extends BasePanelState<AdminPermissionsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final permissions = ref.watch(adminPermissionsControllerProvider);
    final controller = ref.read(adminPermissionsControllerProvider.notifier);

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
                  Text('Yetki ayarları', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Seans bitimi eğitmene ne zaman hatırlatılsın?', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Bildirim seans bitiminden sonra gider', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            for (final delay in TrainerReminderDelay.values)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: delay == TrainerReminderDelay.values.last ? 0 : AppSpacing.sm),
                                  child: _DelayChip(
                                    label: delay.label,
                                    selected: permissions.trainerReminderDelay == delay,
                                    onTap: () => controller.setReminderDelay(delay),
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
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      children: [
                        _PermissionToggle(
                          title: 'Online Rezervasyon',
                          note: 'Üyeler Keşfet üzerinden grup derslerine katılabilir',
                          value: permissions.onlineBookingEnabled,
                          onTap: controller.toggleOnlineBooking,
                          showDivider: true,
                        ),
                        _PermissionToggle(
                          title: 'Paket süresi bitince seans oluşturulabilsin mi?',
                          note: 'Kapalıysa paketi bitmiş üyeye yeni seans planlanamaz',
                          value: permissions.allowSessionsAfterPackageExpiry,
                          onTap: controller.toggleAllowSessionsAfterExpiry,
                          showDivider: true,
                        ),
                        _PermissionToggle(
                          title: 'Üye seans iptal edebilir',
                          note: 'Kapalıysa iptal yalnızca antrenör/yönetici yapabilir',
                          value: permissions.memberCanCancelSession,
                          onTap: controller.toggleMemberCanCancel,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Bu ayarlar tüm antrenör ve üyeleri etkiler; kaydettiğinizde uygulama yeniden başlatılmadan geçerli olur.',
                    style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(label: 'Kaydet', onPressed: () => ref.read(panelStackControllerProvider.notifier).pop()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DelayChip extends StatelessWidget {
  const _DelayChip({required this.label, required this.selected, required this.onTap});

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
          child: Text(label, style: context.appTypography.headingSmall.copyWith(fontSize: 14, color: selected ? colors.onPrimary : colors.onSurfaceVariant)),
        ),
      ),
    );
  }
}

class _PermissionToggle extends StatelessWidget {
  const _PermissionToggle({required this.title, required this.note, required this.value, required this.onTap, required this.showDivider});

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
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: colors.outline)) : null),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                Text(note, style: typography.caption.copyWith(color: colors.onSurfaceMuted, height: 1.4)),
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
              decoration: BoxDecoration(color: value ? colors.primary : colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(width: 26, height: 26, decoration: BoxDecoration(color: colors.onSurface, shape: BoxShape.circle)),
            ),
          ),
        ],
      ),
    );
  }
}
