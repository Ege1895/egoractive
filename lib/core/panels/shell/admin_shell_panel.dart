import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subscription/subscription_status_banner.dart';
import '../../remote_config/remote_config_service.dart';
import '../base_panel.dart';
import 'app_tab_shell.dart';
import '../../../modules/expenses/ui/panels/admin_expenses_panel.dart';
import '../../../modules/gyms/ui/panels/admin_home_panel.dart';
import '../../../modules/gyms/ui/panels/admin_settings_panel.dart';
import '../../../modules/members/ui/panels/admin_member_list_panel.dart';
import '../../../modules/sessions/ui/panels/admin_calendar_panel.dart';

/// Admin rolü kök shell'i — tasarımdaki `adTabs()` sekme setinin karşılığı
/// (Ana Sayfa · Üyeler · Seanslar · Finans · Ayarlar).
class AdminShellPanel extends BasePanel {
  const AdminShellPanel({super.key});

  @override
  ConsumerState<AdminShellPanel> createState() => _AdminShellPanelState();
}

class _AdminShellPanelState extends BasePanelState<AdminShellPanel> {
  @override
  Widget build(BuildContext context) {
    return AppTabShell(
      topBanner: const SubscriptionStatusBanner(),
      items: [
        AppTabItem(
          icon: Icons.home_rounded,
          label: ref.watch(rcTextProvider(RemoteConfigKeys.shellTabHome)),
          builder: (_) => const AdminHomePanel(),
        ),
        AppTabItem(
          icon: Icons.groups_rounded,
          label: ref.watch(
            rcTextProvider(RemoteConfigKeys.shellAdminTabUyeler),
          ),
          builder: (_) => const AdminMemberListPanel(),
        ),
        AppTabItem(
          icon: Icons.event_note_rounded,
          label: ref.watch(
            rcTextProvider(RemoteConfigKeys.shellAdminTabSeanslar),
          ),
          builder: (_) => const AdminCalendarPanel(),
        ),
        AppTabItem(
          icon: Icons.payments_rounded,
          label: ref.watch(
            rcTextProvider(RemoteConfigKeys.shellAdminTabFinans),
          ),
          builder: (_) => const AdminExpensesPanel(),
        ),
        AppTabItem(
          icon: Icons.settings_rounded,
          label: ref.watch(
            rcTextProvider(RemoteConfigKeys.shellAdminTabAyarlar),
          ),
          builder: (_) => const AdminSettingsPanel(),
        ),
      ],
    );
  }
}
