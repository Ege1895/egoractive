import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../controller/admin_group_sessions_controller.dart';
import '../../domain/admin_group_session.dart';
import 'create_group_session_panel.dart';

/// Admin 11 · Grup Dersleri — kontenjan doluluk göstergesi, + Grup dersi.
class AdminGroupSessionsPanel extends BasePanel {
  const AdminGroupSessionsPanel({super.key});

  @override
  ConsumerState<AdminGroupSessionsPanel> createState() => _AdminGroupSessionsPanelState();
}

class _AdminGroupSessionsPanelState extends BasePanelState<AdminGroupSessionsPanel> {
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final groups = ref.watch(adminGroupSessionsControllerProvider);

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
                  Expanded(child: Text('Grup dersleri', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      onTap: () => ref.read(panelStackControllerProvider.notifier).push(const CreateGroupSessionPanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text('+ Grup dersi', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onPrimary)),
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
                  for (final group in groups) _GroupCard(group: group),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final AdminGroupSession group;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final ratio = group.capacity == 0 ? 0.0 : group.taken / group.capacity;
    final (capFg, barColor, note) = group.isFull
        ? (colors.error, colors.error, 'Kontenjan doldu')
        : group.remaining <= 2
            ? (colors.onWarningContainer, colors.warning, 'Son ${group.remaining} yer')
            : (colors.onSurfaceMuted, colors.primary, 'Yer var');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
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
                    Text(group.name, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 17)),
                    Text(group.meta, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${group.taken}/${group.capacity}', style: typography.dataMedium.copyWith(color: capFg, fontSize: 19)),
                  Text('kontenjan', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: LinearProgressIndicator(value: ratio.clamp(0, 1), minHeight: 8, backgroundColor: colors.surfaceRaised, valueColor: AlwaysStoppedAnimation(barColor)),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: Text(note, style: typography.bodyMedium.copyWith(color: capFg, fontSize: 13))),
              Text('Katılımcıları gör', style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
