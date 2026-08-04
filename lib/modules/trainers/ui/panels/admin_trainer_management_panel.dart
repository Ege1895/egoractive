import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/admin_trainers_controller.dart';
import '../../domain/admin_trainer_summary.dart';

/// Admin 3 · Antrenör Yönetimi — liste + antrenör ekle (alt sayfa formu).
class AdminTrainerManagementPanel extends BasePanel {
  const AdminTrainerManagementPanel({super.key});

  @override
  ConsumerState<AdminTrainerManagementPanel> createState() => _AdminTrainerManagementPanelState();
}

class _AdminTrainerManagementPanelState extends BasePanelState<AdminTrainerManagementPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final trainers = ref.watch(adminTrainersControllerProvider);

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
                  Expanded(child: Text('Antrenörler', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                  Text('${trainers.length} kişi', style: typography.headingSmall.copyWith(color: colors.onSurfaceMuted, fontSize: 15)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                children: [
                  for (final trainer in trainers) _TrainerRow(trainer: trainer),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, 0, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(
                label: '+ Antrenör ekle',
                variant: AppButtonVariant.secondary,
                onPressed: () => _showAddTrainerSheet(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTrainerSheet(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => const _AddTrainerSheet(),
    );
  }
}

class _TrainerRow extends StatelessWidget {
  const _TrainerRow({required this.trainer});

  final AdminTrainerSummary trainer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(trainer.initials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainer.name, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                Text(
                  '${trainer.specialties.join(", ")} · ${trainer.memberCount} üye',
                  style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
        ],
      ),
    );
  }
}

class _AddTrainerSheet extends ConsumerStatefulWidget {
  const _AddTrainerSheet();

  @override
  ConsumerState<_AddTrainerSheet> createState() => _AddTrainerSheetState();
}

class _AddTrainerSheetState extends ConsumerState<_AddTrainerSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final Set<String> _selectedSpecialties = {};

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        AppSpacing.lg,
        AppSpacing.screenEdge,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 44, height: 5, decoration: BoxDecoration(color: colors.outlineStrong, borderRadius: BorderRadius.circular(AppSpacing.radiusPill))),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Antrenör ekle', style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 22)),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(label: 'Ad soyad', controller: _nameController, hint: 'Emre Kaya'),
          const SizedBox(height: AppSpacing.md),
          AppTextField(label: 'Telefon', controller: _phoneController, keyboardType: TextInputType.phone, hint: '0542 907 33 18'),
          const SizedBox(height: AppSpacing.md),
          Text('Uzmanlık', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final specialty in trainerSpecialtyOptions)
                _SpecialtyChip(
                  label: specialty,
                  selected: _selectedSpecialties.contains(specialty),
                  onTap: () => setState(() {
                    _selectedSpecialties.contains(specialty) ? _selectedSpecialties.remove(specialty) : _selectedSpecialties.add(specialty);
                  }),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Antrenörü ekle',
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;
              final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
              final initials = words.take(2).map((w) => w[0]).join().toUpperCase();
              ref.read(adminTrainersControllerProvider.notifier).addTrainer(
                    AdminTrainerSummary(
                      id: name.toLowerCase().replaceAll(' ', '-'),
                      initials: initials,
                      name: name,
                      phone: _phoneController.text.trim(),
                      specialties: _selectedSpecialties.isEmpty ? ['Fonksiyonel'] : _selectedSpecialties.toList(),
                      memberCount: 0,
                    ),
                  );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          constraints: const BoxConstraints(minHeight: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(color: selected ? colors.primary : colors.outlineStrong),
          ),
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(fontSize: 14, color: selected ? colors.onPrimary : colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
