import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../gyms/ui/panels/gym_setup_panel.dart';
import 'phone_login_panel.dart';

enum _TrainerPath { linked, newGym }

/// Ortak 2 · Antrenör Alt Seçimi — [OnboardingRolePanel]'de "Antrenörüm"
/// seçilince açılır. "Bir salona bağlıyım" → [PhoneLoginPanel] (mevcut
/// salonuna antrenör olarak eklenmiş biri girişi). "Yeni salon açmak
/// istiyorum" → [GymSetupPanel] (kendi salonunu kaydedip admin olarak
/// devam edecek).
class OnboardingTrainerPathPanel extends BasePanel {
  const OnboardingTrainerPathPanel({super.key});

  @override
  ConsumerState<OnboardingTrainerPathPanel> createState() => _OnboardingTrainerPathPanelState();
}

class _OnboardingTrainerPathPanelState extends BasePanelState<OnboardingTrainerPathPanel> {
  _TrainerPath? _selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(onTap: () => ref.read(panelStackControllerProvider.notifier).pop()),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Bir salona bağlı mısın?', style: typography.headingLarge.copyWith(color: colors.onSurface, fontSize: 28)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Zaten çalıştığın bir stüdyo varsa oraya bağlan; yoksa kendi salonunu sen oluştur.',
                style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 15),
              ),
              const SizedBox(height: AppSpacing.xl),
              _PathCard(
                title: 'Bir salona bağlı çalışıyorum',
                note: 'Salon yönetimi beni zaten sisteme eklemiş olmalı',
                selected: _selected == _TrainerPath.linked,
                onTap: () => setState(() => _selected = _TrainerPath.linked),
              ),
              const SizedBox(height: AppSpacing.md),
              _PathCard(
                title: 'Yeni bir salon açmak istiyorum',
                note: 'Kendi stüdyomu/salonumu ilk kez kaydediyorum',
                selected: _selected == _TrainerPath.newGym,
                onTap: () => setState(() => _selected = _TrainerPath.newGym),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(_hint, style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
              const Spacer(),
              AppButton(
                label: _selected == _TrainerPath.newGym ? 'Salon oluşturmaya geç' : 'Girişe geç',
                onPressed: _selected == null ? null : _onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _hint => switch (_selected) {
        _TrainerPath.linked => 'Numaran sistemde yoksa salon yönetiminden seni eklemesini isteyebilirsin.',
        _TrainerPath.newGym => 'Salon bilgilerini girdikten sonra yönetici olarak giriş yapacaksın.',
        null => 'Numaran sistemde yoksa salon yönetiminden seni eklemesini isteyebilirsin.',
      };

  void _onContinue() {
    final panelStack = ref.read(panelStackControllerProvider.notifier);
    if (_selected == _TrainerPath.newGym) {
      panelStack.push(const GymSetupPanel());
    } else {
      panelStack.push(const PhoneLoginPanel());
    }
  }
}

class _PathCard extends StatelessWidget {
  const _PathCard({required this.title, required this.note, required this.selected, required this.onTap});

  final String title;
  final String note;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Material(
      color: selected ? colors.primaryContainer : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: selected ? colors.primary : colors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? colors.primary : colors.outlineStrong, width: 2),
                  ),
                  child: selected
                      ? Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: colors.primary))
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(note, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 14)),
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
