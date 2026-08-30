import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base_panel.dart';
import 'app_tab_shell.dart';
import '../../../modules/group_sessions/ui/panels/discover_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_calendar_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_home_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_members_list_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_profile_panel.dart';

/// Antrenör rolü kök shell'i — tasarımdaki `trTabs()` sekme setinin karşılığı
/// (Ana Sayfa · Takvimim · Üyelerim · Keşfet · Profil). "Keşfet", üyenin
/// gördüğü aynı [DiscoverPanel] — antrenör grup dersi/etkinlikleri sadece
/// görüntüler, panel kendi içinde role göre katılım butonunu/kontenjan
/// kısıtını gizliyor (bkz. `discover_panel.dart`'taki `isTrainer`). "Raporum"
/// sekmesi buradan kaldırılıp Profil ekranındaki bir nav satırına taşındı —
/// alt navigasyon 6 sekmeyle kalabalık duruyordu.
class TrainerShellPanel extends BasePanel {
  const TrainerShellPanel({super.key});

  @override
  ConsumerState<TrainerShellPanel> createState() => _TrainerShellPanelState();
}

class _TrainerShellPanelState extends BasePanelState<TrainerShellPanel> {
  @override
  Widget build(BuildContext context) {
    return AppTabShell(
      items: [
        AppTabItem(
          icon: Icons.home_rounded,
          label: 'Ana Sayfa',
          builder: (_) => const TrainerHomePanel(),
        ),
        AppTabItem(
          icon: Icons.calendar_month_rounded,
          label: 'Takvimim',
          builder: (_) => const TrainerCalendarPanel(),
        ),
        AppTabItem(
          icon: Icons.groups_rounded,
          label: 'Üyelerim',
          builder: (_) => const TrainerMembersListPanel(),
        ),
        AppTabItem(
          icon: Icons.explore_rounded,
          label: 'Keşfet',
          builder: (_) => const DiscoverPanel(),
        ),
        AppTabItem(
          icon: Icons.person_rounded,
          label: 'Profil',
          builder: (_) => const TrainerProfilePanel(),
        ),
      ],
    );
  }
}
