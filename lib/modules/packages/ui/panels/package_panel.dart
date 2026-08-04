import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/progress_ring.dart';
import '../../controller/package_controller.dart';

/// Üye 4 · Paketim — fiyat hiçbir yerde gösterilmez.
class PackagePanel extends BasePanel {
  const PackagePanel({super.key});

  @override
  ConsumerState<PackagePanel> createState() => _PackagePanelState();
}

class _PackagePanelState extends BasePanelState<PackagePanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final pkg = ref.watch(packageControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
          children: [
            Text('Paketim', style: typography.headingLarge.copyWith(color: colors.onSurface)),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ProgressRing(
                        size: 96,
                        progress: pkg.remainingSessions / pkg.totalSessions,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${pkg.remainingSessions}', style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 32)),
                            Text('kalan', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pkg.name, style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 19)),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${pkg.remainingSessions} dersin kaldı. Telafi hakkın: ${pkg.makeupSessions} seans.',
                              style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(child: _InfoTile(label: 'Başlangıç', value: pkg.startDate)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: _InfoTile(label: 'Bitiş', value: pkg.endDate)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.warningContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.warning.withValues(alpha: 0.32)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(color: colors.warning, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text('!', style: typography.headingSmall.copyWith(color: colors.warningContainer, fontSize: 14)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Son ${pkg.remainingSessions} dersin kaldı',
                          style: typography.headingSmall.copyWith(color: colors.onWarningContainer, fontSize: 16),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Paket bitmeden yenilemek istersen antrenörün ${pkg.trainerName} ile konuşabilirsin.',
                          style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(color: colors.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Antrenörün', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                        Text(
                          '${pkg.trainerName} · ${pkg.trainerSpecialty}',
                          style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      pkg.trainerInitials,
                      style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
          Text(value, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
        ],
      ),
    );
  }
}
