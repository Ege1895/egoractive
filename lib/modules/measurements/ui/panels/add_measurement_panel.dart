import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../controller/measurements_controller.dart';
import '../../domain/measurement_metric.dart';

/// Üye 3 · Yeni Ölçüm Ekle — alanlar mevcut değerle dolu, boş bırakılan
/// alan o kayıtta atlanır (grafikte kırılma olmaz).
class AddMeasurementPanel extends BasePanel {
  const AddMeasurementPanel({super.key});

  @override
  ConsumerState<AddMeasurementPanel> createState() => _AddMeasurementPanelState();
}

class _AddMeasurementPanelState extends BasePanelState<AddMeasurementPanel> {
  late final Map<MeasurementMetric, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final points = ref.read(measurementsControllerProvider).points;
    _controllers = {
      for (final metric in MeasurementMetric.values)
        metric: TextEditingController(text: metric == MeasurementMetric.bacak ? '' : points[metric]?.value ?? ''),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final points = ref.watch(measurementsControllerProvider).points;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Yeni ölçüm', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                  GestureDetector(
                    onTap: () => ref.read(panelStackControllerProvider.notifier).pop(),
                    child: Text('Vazgeç', style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                Text('Ölçüm tarihi', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                                Text('3 Ağustos 2026', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 17)),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            constraints: const BoxConstraints(minHeight: 44),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                            ),
                            child: Text('Değiştir', style: typography.headingSmall.copyWith(color: colors.onSurfaceVariant, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('ÖLÇÜLER', style: typography.caption.copyWith(color: colors.onSurfaceMuted, letterSpacing: 1.2)),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < MeasurementMetric.values.length; i++)
                            _MeasurementField(
                              metric: MeasurementMetric.values[i],
                              lastValueLabel: points[MeasurementMetric.values[i]]?.value,
                              controller: _controllers[MeasurementMetric.values[i]]!,
                              showDivider: i < MeasurementMetric.values.length - 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                        border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
                      ),
                      child: Text(
                        'Ölçüyü boş bırakırsan o nokta bu kayıtta atlanır, grafiğinde kırılma olmaz.',
                        style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.xl),
              decoration: BoxDecoration(color: colors.background, border: Border(top: BorderSide(color: colors.outline))),
              child: AppButton(label: 'Kaydet', onPressed: _save),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final values = <MeasurementMetric, double>{};
    for (final entry in _controllers.entries) {
      final raw = entry.value.text.trim().replaceAll(',', '.');
      final parsed = double.tryParse(raw);
      if (parsed != null) values[entry.key] = parsed;
    }
    await ref.read(measurementsControllerProvider.notifier).addMeasurement(values);
    if (!mounted) return;
    ref.read(panelStackControllerProvider.notifier).pop();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.metric,
    required this.lastValueLabel,
    required this.controller,
    required this.showDivider,
  });

  final MeasurementMetric metric;
  final String? lastValueLabel;
  final TextEditingController controller;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: colors.outline)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(metric.label, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                Text(
                  lastValueLabel == null ? 'İlk ölçüm' : 'Son: $lastValueLabel cm',
                  style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 96,
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceRaised,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
              border: Border.all(
                color: controller.text.isEmpty ? colors.outline : colors.primary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
                    style: typography.dataSmall.copyWith(fontSize: 17, color: colors.onSurface),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text('cm', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
