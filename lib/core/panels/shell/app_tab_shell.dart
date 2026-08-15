import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_theme.dart';

class AppTabItem {
  const AppTabItem({
    required this.icon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final WidgetBuilder builder;
}

/// Rol bazlı 5 sekmeli alt tab bar iskeleti (CLAUDE.md §5 — her rol kendi
/// shell'i içinde gezinir). Tasarımdaki `adTabs`/`trTabs`/`tabs` yapılarının
/// Flutter karşılığı: aktif sekme [AppColorScheme.onPrimaryContainer],
/// pasif sekme [AppColorScheme.onSurfaceMuted] rengini alır.
class AppTabShell extends StatefulWidget {
  const AppTabShell({required this.items, this.bottomAdSlot, this.topBanner, this.onTabSelected, super.key});

  final List<AppTabItem> items;

  /// F6-2 — tab bar'ın hemen üstüne yerleştirilen opsiyonel reklam alanı.
  /// Sadece `MemberShellPanel` bunu doldurur; admin/antrenör shell'lerinde
  /// `null` kalır.
  final Widget? bottomAdSlot;

  /// F6-3 — ekranın en üstüne, hangi sekmede olunursa olsun sabit kalan
  /// opsiyonel uyarı şeridi. Sadece `AdminShellPanel` bunu dolduruyor
  /// (abonelik durumu uyarısı) — antrenör/üye shell'lerinde `null` kalır.
  final Widget? topBanner;

  /// F6-2 — kullanıcı bir sekmeye dokunduğunda (yeni index ne olursa olsun)
  /// tetiklenir. `MemberShellPanel` bunu, "Ana Sayfa"ya dönüşü interstitial
  /// reklam için doğal bir geçiş anı olarak işaretlemek amacıyla kullanır.
  final ValueChanged<int>? onTabSelected;

  @override
  State<AppTabShell> createState() => _AppTabShellState();
}

class _AppTabShellState extends State<AppTabShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (widget.topBanner != null) widget.topBanner!,
            Expanded(
              child: IndexedStack(
                index: _index,
                children: [
                  for (final item in widget.items) Builder(builder: item.builder),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outline)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.bottomAdSlot != null) widget.bottomAdSlot!,
              SizedBox(
                height: 64,
                child: Row(
                  children: [
                    for (var i = 0; i < widget.items.length; i++)
                      Expanded(
                        child: _TabButton(
                          item: widget.items[i],
                          selected: i == _index,
                          onTap: () {
                            setState(() => _index = i);
                            widget.onTabSelected?.call(i);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.item, required this.selected, required this.onTap});

  final AppTabItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final tint = selected ? colors.onPrimaryContainer : colors.onSurfaceMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 22, color: tint),
              const SizedBox(height: AppSpacing.xs),
              Text(
                item.label,
                style: context.appTypography.caption.copyWith(color: tint, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
