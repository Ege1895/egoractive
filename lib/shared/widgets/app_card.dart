import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// CLAUDE.md §2.4 bileşen kütüphanesi — tasarım dilindeki tek kart tipi:
/// [surface] zemin, ince [outline] kenarlık, 20pt yarıçap. Gölge yok —
/// hiyerarşi katman ve kenarlıktan doğuyor (koyu temada gölge görünmez).
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: child,
    );
  }
}
