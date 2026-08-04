import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/trainer_members_controller.dart';
import '../../domain/trainer_member_summary.dart';
import 'trainer_member_detail_panel.dart';

enum _MemberFilter { all, endingSoon, noPackage }

/// Antrenör 3 · Üyelerim (Üyelerim sekmesi kökü) — sadece bu antrenöre bağlı
/// mock üyeler; filtre çipleri kalan ders sayısına göre çalışır.
class TrainerMembersListPanel extends ConsumerStatefulWidget {
  const TrainerMembersListPanel({super.key});

  @override
  ConsumerState<TrainerMembersListPanel> createState() => _TrainerMembersListPanelState();
}

class _TrainerMembersListPanelState extends ConsumerState<TrainerMembersListPanel> {
  _MemberFilter _filter = _MemberFilter.all;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final members = ref.watch(trainerMembersControllerProvider);
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
                      Text('Üyelerim', style: typography.headingLarge.copyWith(color: colors.onSurface)),
                      Text('${members.length} üye', style: typography.headingSmall.copyWith(color: colors.onSurfaceMuted, fontSize: 15)),
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
                            controller: _searchController,
                            onChanged: (value) => setState(() => _query = value),
                            style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15),
                            decoration: InputDecoration(
                              hintText: 'Üye ara',
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
                        _FilterChip(
                          label: 'Paketi bitiyor',
                          selected: _filter == _MemberFilter.endingSoon,
                          onTap: () => setState(() => _filter = _MemberFilter.endingSoon),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: 'Paketi yok',
                          selected: _filter == _MemberFilter.noPackage,
                          onTap: () => setState(() => _filter = _MemberFilter.noPackage),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Bu filtreye uyan üye yok.',
                        style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
                      children: [
                        for (final member in filtered) _MemberRow(member: member),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(TrainerMemberSummary member) {
    return switch (_filter) {
      _MemberFilter.all => true,
      _MemberFilter.endingSoon => member.remainingSessions > 0 && member.remainingSessions <= 2,
      _MemberFilter.noPackage => member.remainingSessions == 0,
    };
  }

  bool _matchesQuery(TrainerMemberSummary member) {
    if (_query.isEmpty) return true;
    return member.name.toLowerCase().contains(_query.toLowerCase());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            style: context.appTypography.headingSmall.copyWith(
              fontSize: 14,
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.member});

  final TrainerMemberSummary member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final leftColor = member.remainingSessions == 0
        ? colors.error
        : (member.remainingSessions <= 2 ? colors.onWarningContainer : colors.onSurface);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: () => ref.read(panelStackControllerProvider.notifier).push(TrainerMemberDetailPanel(memberId: member.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
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
              child: Text(member.initials, style: typography.headingSmall.copyWith(color: colors.onPrimaryContainer, fontSize: 15)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 16)),
                  Text(member.packageName, style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${member.remainingSessions}', style: typography.headingSmall.copyWith(color: leftColor, fontSize: 16)),
                Text('kalan ders', style: typography.caption.copyWith(color: colors.onSurfaceMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
