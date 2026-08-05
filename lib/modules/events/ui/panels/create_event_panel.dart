import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/gym_events_controller.dart';
import '../../domain/gym_event.dart';

/// Admin 13 · Etkinlik Oluştur — lokasyon, tarih/saat, kontenjan.
class CreateEventPanel extends BasePanel {
  const CreateEventPanel({super.key});

  @override
  ConsumerState<CreateEventPanel> createState() => _CreateEventPanelState();
}

class _CreateEventPanelState extends BasePanelState<CreateEventPanel> {
  final _nameController = TextEditingController(text: 'Belgrad Ormanı Koşusu');
  final _locationController = TextEditingController(text: 'Kemerburgaz, Neşetsuyu girişi');
  final _dateController = TextEditingController(text: '16 Ağu 2026');
  final _timeController = TextEditingController(text: '08:00');
  final _descriptionController = TextEditingController(text: '8 km tempolu koşu, ardından esneme. Kendi suyunuzu getirin.');
  int? _capacity = 40;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Etkinlik oluştur', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
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
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(label: 'Etkinlik adı', controller: _nameController),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(label: 'Lokasyon', controller: _locationController),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(child: AppTextField(label: 'Tarih', controller: _dateController)),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: AppTextField(label: 'Saat', controller: _timeController, keyboardType: TextInputType.datetime)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(label: 'Açıklama', controller: _descriptionController),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kontenjan', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                              Text('Boş bırakırsanız sınırsız olur', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                            ],
                          ),
                        ),
                        _StepButton(
                          icon: Icons.remove,
                          onTap: () => setState(() => _capacity = _capacity == null ? null : (_capacity! > 1 ? _capacity! - 1 : null)),
                        ),
                        SizedBox(width: 40, child: Text(_capacity?.toString() ?? '∞', textAlign: TextAlign.center, style: typography.dataMedium.copyWith(color: colors.onSurface, fontSize: 18))),
                        _StepButton(icon: Icons.add, filled: true, onTap: () => setState(() => _capacity = (_capacity ?? 0) + 1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(
                label: 'Etkinliği oluştur',
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) return;
                  final dateParts = _dateController.text.trim().split(' ');
                  ref.read(gymEventsControllerProvider.notifier).addEvent(
                        GymEvent(
                          id: name.toLowerCase().replaceAll(' ', '-'),
                          name: name,
                          location: _locationController.text.trim(),
                          day: dateParts.isNotEmpty ? dateParts.first : '1',
                          month: dateParts.length > 1 ? dateParts[1] : '',
                          meta: _descriptionController.text.trim(),
                          joined: 0,
                          capacity: _capacity,
                        ),
                      );
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
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap, this.filled = false});

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: filled ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        child: Container(width: 40, height: 40, alignment: Alignment.center, child: Icon(icon, color: filled ? colors.onPrimary : colors.onSurfaceVariant, size: 18)),
      ),
    );
  }
}
