import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_theme.dart';

/// Panel başlıklarındaki "‹" geri tuşu — tasarımdaki ortak header düğmesi.
class AppBackButton extends StatelessWidget {
  const AppBackButton({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
            border: Border.all(color: colors.outlineStrong),
          ),
          child: Icon(Icons.chevron_left, color: colors.onSurfaceVariant),
        ),
      ),
    );
  }
}
