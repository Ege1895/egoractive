import 'package:flutter/material.dart';

import '../../constants/app_spacing.dart';
import '../../theme/app_theme.dart';

/// P1-P5 panel görevleri devreye girene kadar sekme içeriği yerine geçer.
class PlaceholderTabContent extends StatelessWidget {
  const PlaceholderTabContent({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenEdge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: typography.headingLarge.copyWith(
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Bu sekme henüz doldurulmadı — ilgili panel görevi tamamlanınca burada gerçek içerik olacak.',
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurfaceMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
