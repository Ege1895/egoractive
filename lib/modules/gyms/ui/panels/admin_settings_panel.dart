import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/feature_flags.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/controller/auth_controller.dart';
import '../../../auth/ui/panels/phone_login_panel.dart';
import '../../../events/ui/panels/admin_events_panel.dart';
import '../../../feedback/ui/panels/admin_feedback_list_panel.dart';
import '../../../group_sessions/ui/panels/admin_group_sessions_panel.dart';
import '../../../notifications/ui/panels/send_notification_panel.dart';
import '../../../packages/ui/panels/studio_packages_panel.dart';
import '../../../sessions/ui/panels/admin_session_management_panel.dart';
import '../../../trainers/ui/panels/admin_trainer_management_panel.dart';
import '../../../reports/ui/panels/admin_dashboard_panel.dart';
import 'admin_permissions_panel.dart';
import 'gym_info_panel.dart';
import 'gym_rules_view_panel.dart';

/// Admin · Ayarlar (Ayarlar sekmesi kökü) — kurulum ekranlarına giriş
/// noktası: Salon Bilgileri, Antrenör Yönetimi, Stüdyo Paketleri.
class AdminSettingsPanel extends ConsumerWidget {
  const AdminSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    final groupSessionsEnabled = ref.watch(featureFlagsProvider).isGroupSessionsEnabled;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
          children: [
            Text('Ayarlar', style: typography.headingLarge.copyWith(color: colors.onSurface)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                children: [
                  _NavRow(label: 'Salon bilgileri', onTap: () => panelStack.push(const GymInfoPanel())),
                  _NavRow(label: 'Antrenör yönetimi', onTap: () => panelStack.push(const AdminTrainerManagementPanel())),
                  _NavRow(label: 'Stüdyo paketleri', onTap: () => panelStack.push(const StudioPackagesPanel())),
                  _NavRow(label: 'Raporlar', isLast: true, onTap: () => panelStack.push(const AdminDashboardPanel())),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                children: [
                  _NavRow(label: 'Ders / seans yönetimi', onTap: () => panelStack.push(const AdminSessionManagementPanel())),
                  if (groupSessionsEnabled)
                    _NavRow(label: 'Grup dersleri', onTap: () => panelStack.push(const AdminGroupSessionsPanel())),
                  _NavRow(label: 'Etkinlikler', isLast: true, onTap: () => panelStack.push(const AdminEventsPanel())),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                children: [
                  _NavRow(label: 'Stüdyo kuralları', onTap: () => panelStack.push(const GymRulesViewPanel(showEditButton: true))),
                  _NavRow(label: 'Yetki ayarları', onTap: () => panelStack.push(const AdminPermissionsPanel())),
                  _NavRow(label: 'Geri bildirimler', onTap: () => panelStack.push(const AdminFeedbackListPanel())),
                  _NavRow(label: 'Bildirim gönder', isLast: true, onTap: () => panelStack.push(const SendNotificationPanel())),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                children: [
                  _NavRow(
                    label: 'Çıkış yap',
                    isLast: true,
                    onTap: () {
                      ref.read(authControllerProvider.notifier).logout();
                      panelStack.replaceRoot(const PhoneLoginPanel());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({required this.label, required this.onTap, this.isLast = false});

  final String label;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: colors.outline))),
        child: Row(
          children: [
            Expanded(child: Text(label, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15))),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
