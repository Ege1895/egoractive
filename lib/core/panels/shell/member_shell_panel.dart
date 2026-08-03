import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base_panel.dart';
import 'app_tab_shell.dart';
import 'placeholder_tab_content.dart';

/// Üye rolü kök shell'i — tasarımdaki `tabs()` sekme setinin karşılığı
/// (Ana Sayfa · Derslerim · Ölçümlerim · Keşfet · Profil).
class MemberShellPanel extends BasePanel {
  const MemberShellPanel({super.key});

  @override
  ConsumerState<MemberShellPanel> createState() => _MemberShellPanelState();
}

class _MemberShellPanelState extends BasePanelState<MemberShellPanel> {
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
          icon: Icons.event_note_rounded,
          label: 'Derslerim',
          builder: (_) => const PlaceholderTabContent(title: 'Derslerim'),
        ),
        AppTabItem(
          icon: Icons.straighten_rounded,
          label: 'Ölçümlerim',
          builder: (_) => const PlaceholderTabContent(title: 'Ölçümlerim'),
        ),
        AppTabItem(
          icon: Icons.explore_rounded,
          label: 'Keşfet',
          builder: (_) => const PlaceholderTabContent(title: 'Keşfet'),
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
