import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../gyms/controller/gym_profile_controller.dart';
import '../../../members/controller/admin_members_controller.dart';
import '../../../members/domain/admin_member_summary.dart';
import '../../controller/send_notification_controller.dart';
import '../../domain/send_notification_form.dart';

// Android bildirim başlığı ~65 karakterden sonra kesiliyor (iOS'ta da APNs
// payload boyutu 4KB'la sınırlı ama pratikte kilit ekranında görünen kısım
// bu aralıkta); mesaj gövdesi için 240 karakter Android/FCM'in yaygın
// önerdiği sınır — ikisi de gerçek push bildirim UI kısıtlarını yansıtıyor.
const _titleMaxLength = 65;
const _messageMaxLength = 240;

/// Admin 20 · Bildirim Gönder — hedef seçici, başlık/mesaj, önizleme.
class SendNotificationPanel extends BasePanel {
  const SendNotificationPanel({super.key});

  @override
  ConsumerState<SendNotificationPanel> createState() =>
      _SendNotificationPanelState();
}

class _SendNotificationPanelState
    extends BasePanelState<SendNotificationPanel> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _titleScrollController = ScrollController();
  final _messageScrollController = ScrollController();

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
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.notificationsTitle),
                      ),
                      style: typography.headingSmall.copyWith(
                        color: colors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () =>
                        ref.read(panelStackControllerProvider.notifier).pop(),
                    child: Text(
                      ref.watch(rcTextProvider(RemoteConfigKeys.commonVazgec)),
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
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.notificationsTargetQuestionLabel,
                      ),
                    ),
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _TargetChip(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .notificationsTargetSelectedMembersOption,
                            ),
                          ),
                          selected:
                              form.targetType ==
                              NotificationTargetType.selectedMembers,
                          onTap: () => controller.setTargetType(
                            NotificationTargetType.selectedMembers,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _TargetChip(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys
                                  .notificationsTargetWholeGymOption,
                            ),
                          ),
                          selected:
                              form.targetType ==
                              NotificationTargetType.wholeGym,
                          onTap: () => controller.setTargetType(
                            NotificationTargetType.wholeGym,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (form.targetType == NotificationTargetType.selectedMembers)
                    InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      onTap: () => _showMemberPicker(context, controller),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          border: Border.all(color: colors.outline),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                form.targetMembers.isEmpty
                                    ? '?'
                                    : '${form.targetMembers.length}',
                                style: typography.headingSmall.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                form.targetMembers.isEmpty
                                    ? ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .notificationsSelectMemberButton,
                                        ),
                                      )
                                    : form.targetMembers.values.join(', '),
                                overflow: TextOverflow.ellipsis,
                                style: typography.headingSmall.copyWith(
                                  color: colors.onSurface,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Text(
                              ref.watch(
                                rcTextProvider(RemoteConfigKeys.commonDegistir),
                              ),
                              style: typography.headingSmall.copyWith(
                                color: colors.onPrimaryContainer,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ref
                                  .watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .notificationsWholeGymSummaryLabel,
                                    ),
                                  )
                                  .replaceAll('{gym}', gymName),
                              style: typography.bodyLarge.copyWith(
                                color: colors.onSurfaceVariant,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            '$memberCount',
                            style: typography.headingSmall.copyWith(
                              color: colors.onPrimaryContainer,
                              fontSize: 15,
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
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Scrollbar(
                          controller: _titleScrollController,
                          thumbVisibility: true,
                          interactive: true,
                          thickness: 4,
                          radius: const Radius.circular(4),
                          child: AppTextField(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.notificationsTitleFieldLabel,
                              ),
                            ),
                            controller: _titleController,
                            scrollController: _titleScrollController,
                            minLines: 1,
                            maxLines: 5,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(_titleMaxLength),
                            ],
                            onChanged: controller.updateTitle,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .notificationsMessageCounterLabel,
                                  ),
                                )
                                .replaceAll('{current}', '${form.title.length}')
                                .replaceAll('{max}', '$_titleMaxLength'),
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Scrollbar(
                          controller: _messageScrollController,
                          thumbVisibility: true,
                          interactive: true,
                          thickness: 4,
                          radius: const Radius.circular(4),
                          child: AppTextField(
                            label: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.notificationsMessageFieldLabel,
                              ),
                            ),
                            controller: _messageController,
                            scrollController: _messageScrollController,
                            minLines: 1,
                            maxLines: 5,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(
                                _messageMaxLength,
                              ),
                            ],
                            onChanged: controller.updateMessage,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            ref
                                .watch(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .notificationsMessageCounterLabel,
                                  ),
                                )
                                .replaceAll(
                                  '{current}',
                                  '${form.message.length}',
                                )
                                .replaceAll('{max}', '$_messageMaxLength'),
                            style: typography.caption.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (form.errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      form.errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.notificationsPreviewLabel,
                            ),
                          ),
                          style: typography.headingSmall.copyWith(
                            color: colors.onPrimaryContainer,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys.notificationsPreviewTemplate,
                                ),
                              )
                              .replaceAll(
                                '{title}',
                                form.title.isEmpty
                                    ? ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .notificationsTitleFieldLabel,
                                        ),
                                      )
                                    : form.title,
                              )
                              .replaceAll(
                                '{message}',
                                form.message.isEmpty
                                    ? ref.watch(
                                        rcTextProvider(
                                          RemoteConfigKeys
                                              .notificationsPreviewMessagePlaceholder,
                                        ),
                                      )
                                    : form.message,
                              ),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.45,
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
              child: AppButton(
                label: form.sent
                    ? ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.notificationsSentButtonLabel,
                        ),
                      )
                    : (form.isSending
                          ? ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .notificationsSendingButtonLabel,
                              ),
                            )
                          : ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.notificationsSendButtonLabel,
                              ),
                            )),
                onPressed:
                    form.sent ||
                        form.isSending ||
                        form.title.trim().isEmpty ||
                        form.message.trim().isEmpty
                    ? null
                    : () async {
                        await controller.send();
                        if (!mounted) return;
                        if (ref.read(sendNotificationControllerProvider).sent) {
                          Future.delayed(const Duration(milliseconds: 600), () {
                            if (mounted) {
                              ref
                                  .read(panelStackControllerProvider.notifier)
                                  .pop();
                            }
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

  void _showMemberPicker(
    BuildContext context,
    SendNotificationController controller,
  ) {
    final colors = context.appColors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
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
                  ref.read(
                    rcTextProvider(
                      RemoteConfigKeys.notificationsSelectMemberButton,
                    ),
                  ),
                  style: context.appTypography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ref.read(
                    rcTextProvider(
                      RemoteConfigKeys.notificationsMemberPickerSubtitle,
                    ),
                  ),
                  style: context.appTypography.bodyMedium.copyWith(
                    color: colors.onSurfaceMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // ref.read ile tek seferlik alınan liste, üyeler Firestore'dan
                // henüz gelmemişse (ilk dinlemede stream henüz ilk
                // snapshot'ını vermemişse) hep boş kalıyordu — Consumer ile
                // reaktif izleniyor (bkz. member_info_panel'deki aynı fix).
                Flexible(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final members = ref.watch(adminMembersControllerProvider);
                      final selected = ref
                          .watch(sendNotificationControllerProvider)
                          .targetMembers;
                      if (members.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.lg,
                          ),
                          child: Text(
                            ref.read(
                              rcTextProvider(
                                RemoteConfigKeys
                                    .notificationsNoMembersEmptyState,
                              ),
                            ),
                            style: context.appTypography.bodyMedium.copyWith(
                              color: colors.onSurfaceMuted,
                            ),
                          ),
                        );
                      }
                      return ListView(
                        shrinkWrap: true,
                        children: [
                          for (final member in members)
                            _MemberOption(
                              member: member,
                              selected: selected.containsKey(member.id),
                              onTap: () => controller.toggleMember(
                                member.id,
                                member.name,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: ref.read(
                    rcTextProvider(RemoteConfigKeys.gymsPermissionsDoneButton),
                  ),
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
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
    _titleScrollController.dispose();
    _messageScrollController.dispose();
    super.dispose();
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
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
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          child: Text(
            label,
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 15,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberOption extends StatelessWidget {
  const _MemberOption({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  final AdminMemberSummary member;
  final bool selected;
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
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                member.initials,
                style: typography.headingSmall.copyWith(
                  color: colors.onPrimaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                member.name,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? colors.primary : Colors.transparent,
                border: Border.all(
                  color: selected ? colors.primary : colors.outlineStrong,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selected
                  ? Icon(Icons.check, size: 14, color: colors.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
