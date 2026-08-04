import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base_panel.dart';
import 'app_tab_shell.dart';
import '../../../modules/trainers/ui/panels/trainer_calendar_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_home_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_members_list_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_profile_panel.dart';
import '../../../modules/trainers/ui/panels/trainer_report_panel.dart';

/// Antrenör rolü kök shell'i — tasarımdaki `trTabs()` sekme setinin karşılığı
/// (Ana Sayfa · Takvimim · Üyelerim · Raporum · Profil).
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
          icon: Icons.insights_rounded,
          label: 'Raporum',
          builder: (_) => const TrainerReportPanel(),
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
