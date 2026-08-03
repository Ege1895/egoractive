import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base_panel.dart';
import 'app_tab_shell.dart';
import 'placeholder_tab_content.dart';

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
          builder: (_) => const PlaceholderTabContent(title: 'Ana Sayfa'),
        ),
        AppTabItem(
          icon: Icons.calendar_month_rounded,
          label: 'Takvimim',
          builder: (_) => const PlaceholderTabContent(title: 'Takvimim'),
        ),
        AppTabItem(
          icon: Icons.groups_rounded,
          label: 'Üyelerim',
          builder: (_) => const PlaceholderTabContent(title: 'Üyelerim'),
        ),
        AppTabItem(
          icon: Icons.insights_rounded,
          label: 'Raporum',
          builder: (_) => const PlaceholderTabContent(title: 'Raporum'),
        ),
        AppTabItem(
          icon: Icons.person_rounded,
          label: 'Profil',
          builder: (_) => const PlaceholderTabContent(title: 'Profil'),
        ),
      ],
    );
  }
}
