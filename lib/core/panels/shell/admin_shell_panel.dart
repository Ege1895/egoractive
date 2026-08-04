import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../base_panel.dart';
import 'app_tab_shell.dart';
import 'placeholder_tab_content.dart';

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
      items: [
        AppTabItem(
          icon: Icons.home_rounded,
          label: 'Ana Sayfa',
          builder: (_) => const PlaceholderTabContent(title: 'Ana Sayfa'),
        ),
        AppTabItem(
          icon: Icons.groups_rounded,
          label: 'Üyeler',
          builder: (_) => const PlaceholderTabContent(title: 'Üyeler'),
        ),
        AppTabItem(
          icon: Icons.event_note_rounded,
          label: 'Seanslar',
          builder: (_) => const PlaceholderTabContent(title: 'Seanslar'),
        ),
        AppTabItem(
          icon: Icons.payments_rounded,
          label: 'Finans',
          builder: (_) => const PlaceholderTabContent(title: 'Finans'),
        ),
        AppTabItem(
          icon: Icons.settings_rounded,
          label: 'Ayarlar',
          builder: (_) => const PlaceholderTabContent(title: 'Ayarlar'),
        ),
      ],
    );
  }
}
