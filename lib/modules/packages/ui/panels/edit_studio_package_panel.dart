import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/studio_packages_controller.dart';
import '../../domain/studio_package.dart';

/// Admin 9 · Paket Ekle / Düzenle — ders tipi ve seans sayısı seçilebilir.
class EditStudioPackagePanel extends BasePanel {
  const EditStudioPackagePanel({this.existing, super.key});

  final StudioPackage? existing;

  bool get isNew => existing == null;

  @override
  ConsumerState<EditStudioPackagePanel> createState() => _EditStudioPackagePanelState();
}

class _EditStudioPackagePanelState extends BasePanelState<EditStudioPackagePanel> {
  late final TextEditingController _nameController;
  late final TextEditingController _sessionCountController;
  late final TextEditingController _validityController;
  late final TextEditingController _priceController;
  late PackageSessionType _sessionType;
  late bool _activeForSale;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _sessionCountController = TextEditingController(text: '${existing?.sessionCount ?? 12}');
    _validityController = TextEditingController(text: '${existing?.validityDays ?? 90}');
    _priceController = TextEditingController(text: '${existing?.priceTl ?? 0}');
    _sessionType = existing?.sessionType ?? PackageSessionType.solo;
    _activeForSale = existing?.activeForSale ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final controller = ref.read(studioPackagesControllerProvider.notifier);
    final sessionCount = int.tryParse(_sessionCountController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;
    final perSession = sessionCount == 0 ? 0 : (price / sessionCount).round();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.isNew ? 'Paket ekle' : 'Paketi düzenle', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                  GestureDetector(
                    onTap: () => ref.read(panelStackControllerProvider.notifier).pop(),
                    child: Text('Vazgeç', style: typography.bodyLarge.copyWith(color: colors.onSurfaceMuted, fontSize: 15)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(label: 'Paket adı', controller: _nameController, hint: 'Birebir 12 Seans'),
                        const SizedBox(height: AppSpacing.md),
                        Text('Ders tipi', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (final type in PackageSessionType.values)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: type == PackageSessionType.values.last ? 0 : AppSpacing.sm),
                                  child: _TypeChip(
                                    label: type.label,
                                    selected: _sessionType == type,
                                    onTap: () => setState(() => _sessionType = type),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'Seans sayısı',
                                controller: _sessionCountController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: AppTextField(label: 'Geçerlilik (gün)', controller: _validityController, keyboardType: TextInputType.number),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Fiyat (₺)',
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text('seans başı ₺$perSession', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.outline))),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Satışta', style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                                    Text('Kapalıysa yeni üyeliklerde görünmez', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _activeForSale = !_activeForSale),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 52,
                                  height: 32,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: _activeForSale ? colors.primary : colors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                                  ),
                                  alignment: _activeForSale ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(width: 26, height: 26, decoration: BoxDecoration(color: colors.onSurface, shape: BoxShape.circle)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!widget.isNew)
                          InkWell(
                            onTap: () async {
                              await controller.deletePackage(widget.existing!.id);
                              if (!mounted) return;
                              ref.read(panelStackControllerProvider.notifier).pop();
                            },
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 60),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Paketi sil', style: typography.bodyLarge.copyWith(color: colors.error, fontSize: 15)),
                                  Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(
                label: 'Kaydet',
                onPressed: () async {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  await controller.addOrUpdate(
                    StudioPackage(
                      id: widget.existing?.id ?? name.toLowerCase().replaceAll(' ', '-'),
                      name: name,
                      sessionType: _sessionType,
                      sessionCount: int.tryParse(_sessionCountController.text) ?? 0,
                      validityDays: int.tryParse(_validityController.text) ?? 0,
                      priceTl: int.tryParse(_priceController.text) ?? 0,
                      activeForSale: _activeForSale,
                    ),
                  );
                  if (!mounted) return;
                  ref.read(panelStackControllerProvider.notifier).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sessionCountController.dispose();
    _validityController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(fontSize: 15, color: selected ? colors.onPrimary : colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
