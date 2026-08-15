import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../gyms/controller/gym_profile_controller.dart';
import '../../../members/controller/admin_members_controller.dart';
import '../../../members/domain/admin_member_summary.dart';
import '../../controller/send_notification_controller.dart';
import '../../domain/send_notification_form.dart';

const _messageMaxLength = 240;

/// Admin 20 · Bildirim Gönder — hedef seçici, başlık/mesaj, önizleme.
class SendNotificationPanel extends BasePanel {
  const SendNotificationPanel({super.key});

  @override
  ConsumerState<SendNotificationPanel> createState() => _SendNotificationPanelState();
}

class _SendNotificationPanelState extends BasePanelState<SendNotificationPanel> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final form = ref.watch(sendNotificationControllerProvider);
    final controller = ref.read(sendNotificationControllerProvider.notifier);
    final gymName = ref.watch(gymProfileControllerProvider).name;
    final memberCount = ref.watch(adminMembersControllerProvider).length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Bildirim gönder', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
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
                  Text('Kime gidecek?', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _TargetChip(
                          label: 'Tek üye',
                          selected: form.targetType == NotificationTargetType.singleMember,
                          onTap: () => controller.setTargetType(NotificationTargetType.singleMember),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TargetChip(
                          label: 'Tüm salon',
                          selected: form.targetType == NotificationTargetType.wholeGym,
                          onTap: () => controller.setTargetType(NotificationTargetType.wholeGym),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (form.targetType == NotificationTargetType.singleMember)
                    InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      onTap: () => _showMemberPicker(context, controller),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusInner), border: Border.all(color: colors.outline)),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(
                                form.targetMemberName == null ? '?' : _initialsOf(form.targetMemberName!),
                                style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 14),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                form.targetMemberName ?? 'Üye seç',
                                style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 15),
                              ),
                            ),
                            Text('Değiştir', style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 13)),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusInner), border: Border.all(color: colors.outline)),
                      child: Row(
                        children: [
                          Expanded(child: Text('$gymName · tüm üyeler', style: typography.bodyLarge.copyWith(color: colors.onSurfaceVariant, fontSize: 15))),
                          Text('$memberCount', style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15)),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(label: 'Başlık', controller: _titleController, onChanged: controller.updateTitle),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(label: 'Mesaj', controller: _messageController, onChanged: controller.updateMessage),
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text('${form.message.length} / $_messageMaxLength', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                        ),
                      ],
                    ),
                  ),
                  if (form.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(form.errorMessage!, style: typography.bodyMedium.copyWith(color: colors.error, fontSize: 13)),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.22)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Önizleme', style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 14)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Egoractive · ${form.title.isEmpty ? "Başlık" : form.title} — ${form.message.isEmpty ? "Mesaj metni…" : form.message}',
                          style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 14, height: 1.45),
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
                label: form.sent ? 'Gönderildi' : (form.isSending ? 'Gönderiliyor…' : 'Gönder'),
                onPressed: form.sent || form.isSending || form.title.trim().isEmpty || form.message.trim().isEmpty
                    ? null
                    : () async {
                        await controller.send();
                        if (!mounted) return;
                        if (ref.read(sendNotificationControllerProvider).sent) {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) ref.read(panelStackControllerProvider.notifier).pop();
                          });
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMemberPicker(BuildContext context, SendNotificationController controller) {
    final colors = context.appColors;
    final members = ref.read(adminMembersControllerProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Üye seç', style: context.appTypography.headingMedium.copyWith(color: colors.onSurface, fontSize: 20)),
                const SizedBox(height: AppSpacing.md),
                for (final member in members) _MemberOption(member: member, onTap: () {
                  controller.selectMember(member.id, member.name);
                  Navigator.of(sheetContext).pop();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}

String _initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.take(2).map((w) => w[0]).join().toUpperCase();
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({required this.label, required this.selected, required this.onTap});

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
          child: Text(label, style: context.appTypography.headingSmall.copyWith(fontSize: 15, color: selected ? colors.onPrimary : colors.onSurfaceVariant)),
        ),
      ),
    );
  }
}

class _MemberOption extends StatelessWidget {
  const _MemberOption({required this.member, required this.onTap});

  final AdminMemberSummary member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(member.initials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 13)),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(member.name, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
