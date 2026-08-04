import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/admin_members_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../domain/admin_member_summary.dart';
import 'member_info_panel.dart';

enum _MemberFilter { all, active, endingSoon, none }

/// Admin 4 · Üye Listesi — arama + filtre çipleri, + Üye ekle.
class AdminMemberListPanel extends ConsumerStatefulWidget {
  const AdminMemberListPanel({super.key});

  @override
  ConsumerState<AdminMemberListPanel> createState() => _AdminMemberListPanelState();
}

class _AdminMemberListPanelState extends ConsumerState<AdminMemberListPanel> {
  _MemberFilter _filter = _MemberFilter.all;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final members = ref.watch(adminMembersControllerProvider);
    final filtered = members.where(_matchesFilter).where(_matchesQuery).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Üyeler', style: typography.headingLarge.copyWith(color: colors.onSurface)),
                      Material(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                          onTap: () {
                            ref.read(newMemberControllerProvider.notifier).reset();
                            ref.read(panelStackControllerProvider.notifier).push(const MemberInfoPanel());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            constraints: const BoxConstraints(minHeight: 40),
                            alignment: Alignment.center,
                            child: Text('+ Üye ekle', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onPrimary)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, size: 18, color: colors.onSurfaceMuted),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            onChanged: (value) => setState(() => _query = value),
                            style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'İsim veya telefon ara',
                              hintStyle: typography.bodyLarge.copyWith(color: colors.onSurfaceMuted, fontSize: 15),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 34,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(label: 'Tümü', selected: _filter == _MemberFilter.all, onTap: () => setState(() => _filter = _MemberFilter.all)),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(label: 'Aktif', selected: _filter == _MemberFilter.active, onTap: () => setState(() => _filter = _MemberFilter.active)),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Bitiyor',
                          selected: _filter == _MemberFilter.endingSoon,
                          onTap: () => setState(() => _filter = _MemberFilter.endingSoon),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(label: 'Paketi yok', selected: _filter == _MemberFilter.none, onTap: () => setState(() => _filter = _MemberFilter.none)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(child: Text('Bu filtreye uyan üye yok.', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted)))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                      children: [
                        for (final member in filtered) _MemberCard(member: member),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(AdminMemberSummary member) {
    return switch (_filter) {
      _MemberFilter.all => true,
      _MemberFilter.active => member.status == MemberPackageStatus.active,
      _MemberFilter.endingSoon => member.status == MemberPackageStatus.endingSoon,
      _MemberFilter.none => member.status == MemberPackageStatus.none,
    };
  }

  bool _matchesQuery(AdminMemberSummary member) {
    if (_query.isEmpty) return true;
    final query = _query.toLowerCase();
    return member.name.toLowerCase().contains(query) || member.phone.contains(query);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
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

class _MemberCard extends ConsumerWidget {
  const _MemberCard({required this.member});

  final AdminMemberSummary member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (chipBg, chipFg) = switch (member.status) {
      MemberPackageStatus.active => (colors.successContainer, colors.onSuccessContainer),
      MemberPackageStatus.endingSoon => (colors.warningContainer, colors.onWarningContainer),
      MemberPackageStatus.none => (colors.errorContainer, colors.onErrorContainer),
    };
    final leftColor = member.status == MemberPackageStatus.none
        ? colors.error
        : (member.status == MemberPackageStatus.endingSoon ? colors.onWarningContainer : colors.onSurface);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: () => ref.read(panelStackControllerProvider.notifier).push(MemberInfoPanel(existing: member)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: colors.outline),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: colors.primaryContainer, shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: Text(member.initials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.name, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                      Text(member.trainerName, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                  decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                  child: Text(member.status.label, style: typography.caption.copyWith(color: chipFg, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Kalan ders', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
                        Text('${member.remainingSessions}', style: typography.headingSmall.copyWith(color: leftColor, fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(color: colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusInner)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Bitiş', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 12)),
                        Text(
                          member.packageEndDate,
                          style: typography.headingSmall.copyWith(color: colors.onSurfaceVariant, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
