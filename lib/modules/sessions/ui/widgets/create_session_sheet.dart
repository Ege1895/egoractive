import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../members/controller/admin_members_controller.dart';
import '../../../members/domain/admin_member_summary.dart';
import '../../../trainers/controller/admin_trainers_controller.dart';
import '../../../trainers/domain/admin_trainer_summary.dart';
import '../../service/sessions_write_service.dart';

/// F3-3 — "+ Seans": üye + antrenör + tarih/saat seçip `sessions`
/// koleksiyonuna gerçek bir doküman yazar.
Future<void> showCreateSessionSheet(BuildContext context, WidgetRef ref, DateTime initialDate) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetContext) => _CreateSessionSheet(initialDate: initialDate),
  );
}

/// F3-3 — "Seansı ertele": mevcut bir seansın `startTime`'ını değiştirir.
Future<void> showRescheduleSessionSheet(
  BuildContext context,
  WidgetRef ref, {
  required String sessionId,
  required DateTime currentStart,
}) async {
  final date = await showDatePicker(
    context: context,
    initialDate: currentStart,
    firstDate: DateTime.now().subtract(const Duration(days: 1)),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );
  if (date == null || !context.mounted) return;
  final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(currentStart));
  if (time == null) return;
  await ref.read(sessionsWriteServiceProvider).rescheduleSession(
        sessionId,
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
}

class _CreateSessionSheet extends ConsumerStatefulWidget {
  const _CreateSessionSheet({required this.initialDate});

  final DateTime initialDate;

  @override
  ConsumerState<_CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends ConsumerState<_CreateSessionSheet> {
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 18, minute: 0);
  AdminMemberSummary? _member;
  AdminTrainerSummary? _trainer;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final members = ref.watch(adminMembersControllerProvider);
    final trainers = ref.watch(adminTrainersControllerProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yeni seans', style: typography.headingMedium.copyWith(color: colors.onSurface, fontSize: 20)),
          const SizedBox(height: AppSpacing.lg),
          _PickerRow(
            label: 'Üye',
            value: _member?.name ?? 'Seç',
            onTap: () => _pickFromList<AdminMemberSummary>(
              title: 'Üye seç',
              items: members,
              labelOf: (m) => m.name,
              onSelected: (m) => setState(() => _member = m),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: 'Antrenör',
            value: _trainer?.name ?? 'Seç',
            onTap: () => _pickFromList<AdminTrainerSummary>(
              title: 'Antrenör seç',
              items: trainers,
              labelOf: (t) => t.name,
              onSelected: (t) => setState(() => _trainer = t),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: 'Tarih',
            value: '${_date.day}.${_date.month}.${_date.year}',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now().subtract(const Duration(days: 1)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _PickerRow(
            label: 'Saat',
            value: _time.format(context),
            onTap: () async {
              final picked = await showTimePicker(context: context, initialTime: _time);
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Oluştur',
            onPressed: _member == null || _trainer == null
                ? null
                : () async {
                    final gymId = await ref.read(activeGymIdProvider.future);
                    if (gymId == null) return;
                    await ref.read(sessionsWriteServiceProvider).createSession(
                          gymId: gymId,
                          trainerId: _trainer!.id,
                          trainerName: _trainer!.name,
                          memberId: _member!.id,
                          memberName: _member!.name,
                          startTime: DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute),
                        );
                    if (context.mounted) Navigator.of(context).pop();
                  },
          ),
        ],
      ),
    );
  }

  void _pickFromList<T>({
    required String title,
    required List<T> items,
    required String Function(T) labelOf,
    required void Function(T) onSelected,
  }) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.appTypography.headingMedium.copyWith(color: colors.onSurface, fontSize: 20)),
              const SizedBox(height: AppSpacing.md),
              for (final item in items)
                InkWell(
                  onTap: () {
                    onSelected(item);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 52),
                    alignment: Alignment.centerLeft,
                    child: Text(labelOf(item), style: context.appTypography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.label, required this.value, required this.onTap});

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
        child: Row(
          children: [
            Expanded(child: Text(label, style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15))),
            Text(value, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15)),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right, color: colors.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
