import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/studio_packages_controller.dart';
import '../../domain/studio_package.dart';
import 'edit_studio_package_panel.dart';

/// Admin 8 · Stüdyo Paketleri — ders tipi rozetleri, + Paket ekle.
class StudioPackagesPanel extends BasePanel {
  const StudioPackagesPanel({super.key});

  @override
  ConsumerState<StudioPackagesPanel> createState() => _StudioPackagesPanelState();
}

class _StudioPackagesPanelState extends BasePanelState<StudioPackagesPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final packages = ref.watch(studioPackagesControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text('Paketler', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      onTap: () => ref.read(panelStackControllerProvider.notifier).push(const EditStudioPackagePanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text('+ Paket ekle', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onPrimary)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  for (final package in packages) _PackageCard(package: package),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends ConsumerWidget {
  const _PackageCard({required this.package});

  final StudioPackage package;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final isSolo = package.sessionType == PackageSessionType.solo;
    final typeBg = isSolo ? colors.primaryContainer : colors.successContainer;
    final typeFg = isSolo ? colors.onPrimaryContainer : colors.onSuccessContainer;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.name, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 17)),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 5),
                          decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                          child: Text(package.sessionType.label, style: typography.caption.copyWith(color: typeFg, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            '${package.sessionCount} seans · ${package.validityDays} gün',
                            style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text('₺${package.priceTl}', style: typography.dataMedium.copyWith(color: colors.onSurface, fontSize: 20)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Material(
                  color: colors.surfaceRaised,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    onTap: () => ref.read(panelStackControllerProvider.notifier).push(EditStudioPackagePanel(existing: package)),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 44),
                      alignment: Alignment.center,
                      child: Text('Düzenle', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onSurfaceVariant)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                constraints: const BoxConstraints(minHeight: 44),
                decoration: BoxDecoration(color: colors.surfaceRaised.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
                alignment: Alignment.center,
                child: Text(
                  package.activeForSale ? 'Satışta' : 'Kapalı',
                  style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onSurfaceMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
