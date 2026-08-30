import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/ad_banner_widget.dart';
import '../../ads/ad_interstitial_gate.dart';
import '../../ads/home_return_signal.dart';
import '../base_panel.dart';
import 'app_tab_shell.dart';
import '../../../modules/auth/ui/panels/profile_panel.dart';
import '../../../modules/group_sessions/ui/panels/discover_panel.dart';
import '../../../modules/measurements/ui/panels/measurements_panel.dart';
import '../../../modules/sessions/ui/panels/member_home_panel.dart';
import '../../../modules/sessions/ui/panels/sessions_list_panel.dart';

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
    return Stack(
      children: [
        AppTabShell(
          bottomAdSlot: const AdBannerWidget(),
          items: _tabItems(),
          // F6-2 — "Ana Sayfa"ya dokunmak, interstitial reklam için doğal
          // bir geçiş anı sayılır (politika: timer ile değil geçiş anında).
          onTabSelected: (index) {
            if (index == 0)
              ref.read(homeReturnSignalProvider.notifier).notify();
          },
        ),
        const AdInterstitialGate(),
      ],
    );
  }

  // F6-2 — geri navigasyonuyla bu shell yeniden aktif panel olduğunda da
  // (ör. pushlanmış bir detay ekranından geri dönüldüğünde) aynı sinyal
  // gönderilir — "geri tuşuyla ana sayfaya dönme" de doğal bir geçiş anı.
  @override
  void onPanelShow() {
    super.onPanelShow();
    ref.read(homeReturnSignalProvider.notifier).notify();
  }

  List<AppTabItem> _tabItems() {
    return [
      AppTabItem(
        icon: Icons.home_rounded,
        label: 'Ana Sayfa',
        builder: (_) => const MemberHomePanel(),
      ),
      AppTabItem(
        icon: Icons.event_note_rounded,
        label: 'Derslerim',
        builder: (_) => const SessionsListPanel(),
      ),
      AppTabItem(
        icon: Icons.straighten_rounded,
        label: 'Ölçümlerim',
        builder: (_) => const MeasurementsPanel(),
      ),
      AppTabItem(
        icon: Icons.explore_rounded,
        label: 'Keşfet',
        builder: (_) => const DiscoverPanel(),
      ),
      AppTabItem(
        icon: Icons.person_rounded,
        label: 'Profil',
        builder: (_) => const ProfilePanel(),
      ),
    ];
  }
}
