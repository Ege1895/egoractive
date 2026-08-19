import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/create_group_session_controller.dart';
import '../../domain/create_group_session_form.dart';

/// Antrenör 7 · Grup Dersi Oluştur — kontenjan ve gün seçimi.
class CreateGroupSessionPanel extends BasePanel {
  const CreateGroupSessionPanel({super.key});

  @override
  ConsumerState<CreateGroupSessionPanel> createState() =>
      _CreateGroupSessionPanelState();
}

class _CreateGroupSessionPanelState
    extends BasePanelState<CreateGroupSessionPanel> {
  late final TextEditingController _titleController;
  late final TextEditingController _studioNameController;

  @override
  void initState() {
    super.initState();
    // Önceki sürümde bu alanın `controller` parametresi hiç verilmemişti —
    // TextField kendi iç state'ini tutuyordu, provider'daki `form.title` ile
    // senkron değildi (ör. panel yeniden build olunca alan sıfırlanabilirdi).
    _titleController = TextEditingController(
      text: ref.read(createGroupSessionControllerProvider).title,
    );
    _studioNameController = TextEditingController(
      text: ref.read(createGroupSessionControllerProvider).studioName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final form = ref.watch(createGroupSessionControllerProvider);
    final controller = ref.read(createGroupSessionControllerProvider.notifier);
    final panelStack = ref.read(panelStackControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Grup dersi oluştur',
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: () => panelStack.pop(),
                    child: Text(
                      'Vazgeç',
                      style: typography.bodyLarge.copyWith(
                        color: colors.onSurfaceMuted,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'Ders adı',
                          controller: _titleController,
                          errorText: form.titleError,
                          onChanged: controller.setTitle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoField(
                                label: 'Başlangıç saati',
                                value: form.startTime,
                                onTap: () =>
                                    _pickStartTime(context, controller, form),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: _InfoField(
                                label: 'Süre',
                                value: '${form.durationMinutes} dk',
                                onTap: () => _pickDuration(
                                  context,
                                  controller,
                                  form.durationMinutes,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Günler',
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            for (
                              var i = 0;
                              i < groupSessionDayLabels.length;
                              i++
                            )
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: i == groupSessionDayLabels.length - 1
                                        ? 0
                                        : AppSpacing.xs,
                                  ),
                                  child: _DayChip(
                                    label: groupSessionDayLabels[i],
                                    selected: form.selectedDays.contains(i + 1),
                                    onTap: () => controller.toggleDay(i + 1),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (form.daysError != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            form.daysError!,
                            style: typography.bodyMedium.copyWith(
                              color: colors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Kontenjan',
                                    style: typography.headingSmall.copyWith(
                                      color: colors.onSurface,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    form.studioName.trim().isEmpty
                                        ? 'Üst sınır ${form.capacityMax} kişi'
                                        : '${form.studioName} için üst sınır ${form.capacityMax} kişi',
                                    style: typography.bodyMedium.copyWith(
                                      color: colors.onSurfaceMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _StepperButton(
                              icon: Icons.remove,
                              onTap: controller.decrementCapacity,
                              filled: false,
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${form.capacity}',
                                textAlign: TextAlign.center,
                                style: typography.headingMedium.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            _StepperButton(
                              icon: Icons.add,
                              onTap: controller.incrementCapacity,
                              filled: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          child: LinearProgressIndicator(
                            value: (form.capacity / form.capacityMax).clamp(
                              0,
                              1,
                            ),
                            minHeight: 6,
                            backgroundColor: colors.surfaceRaised,
                            valueColor: AlwaysStoppedAnimation(colors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 60),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: colors.outline),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Online rezervasyona açık',
                                      style: typography.bodyLarge.copyWith(
                                        color: colors.onSurface,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "Üyeler Keşfet'ten katılabilir",
                                      style: typography.caption.copyWith(
                                        color: colors.onSurfaceMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: controller.toggleOnlineBooking,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 52,
                                  height: 32,
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: form.onlineBookingEnabled
                                        ? colors.primary
                                        : colors.surfaceRaised,
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill,
                                    ),
                                  ),
                                  alignment: form.onlineBookingEnabled
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: colors.onSurface,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Ders yeri (opsiyonel)',
                          hint: 'Örn. Stüdyo 1, Ana salon',
                          controller: _studioNameController,
                          onChanged: controller.setStudioName,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Dersin nerede yapılacağını üyelere gösterir.',
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.md,
                AppSpacing.screenEdge,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (form.errorMessage != null) ...[
                    Text(
                      form.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: form.isSubmitting
                        ? 'Oluşturuluyor…'
                        : 'Grup dersini oluştur',
                    onPressed: form.isSubmitting
                        ? null
                        : () async {
                            if (!await ensureSubscriptionAllowsWrite(
                              context,
                              ref,
                            )) {
                              return;
                            }
                            final success = await controller.submit();
                            if (success) panelStack.pop();
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _studioNameController.dispose();
    super.dispose();
  }
}

Future<void> _pickStartTime(
  BuildContext context,
  CreateGroupSessionController controller,
  CreateGroupSessionForm form,
) async {
  final parts = form.startTime.split(':');
  final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  final picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: hour, minute: minute),
  );
  if (picked == null) return;
  final hh = picked.hour.toString().padLeft(2, '0');
  final mm = picked.minute.toString().padLeft(2, '0');
  controller.setStartTime('$hh:$mm');
}

const _durationOptions = [30, 45, 60, 75, 90, 120];

Future<void> _pickDuration(
  BuildContext context,
  CreateGroupSessionController controller,
  int current,
) {
  final colors = context.appColors;
  final typography = context.appTypography;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Süre seç',
                style: typography.headingMedium.copyWith(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (final minutes in _durationOptions)
                InkWell(
                  onTap: () {
                    controller.setDurationMinutes(minutes);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$minutes dk',
                            style: typography.bodyLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (minutes == current)
                          Icon(Icons.check, color: colors.primary, size: 18),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Material(
      color: colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: typography.caption.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                    Text(
                      value,
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurfaceMuted,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTouchTarget,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 13,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.filled,
  });

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
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: filled ? colors.onPrimary : colors.onSurfaceVariant,
            size: 20,
          ),
        ),
      ),
    );
  }
}
