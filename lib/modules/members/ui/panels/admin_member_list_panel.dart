import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controller/admin_member_list_controller.dart';
import '../../controller/new_member_controller.dart';
import '../../domain/admin_member_summary.dart';
import 'admin_member_detail_panel.dart';
import 'member_info_panel.dart';

enum _MemberFilter { all, active, endingSoon, none }

const _searchDebounce = Duration(milliseconds: 300);
const _loadMoreThreshold = 400.0;

/// Admin 4 · Üye Listesi — arama + filtre çipleri, + Üye ekle.
///
/// F7-2 — büyük salonlarda (10.000+ üye) ilk render'ı 3 saniyenin altında
/// tutmak için `AdminMemberListController`'ın sayfalı verisini kullanır
/// (bkz. `scripts/seed_load_test_data.ts`). Filtre çipleri o an yüklü
/// sayfalar üzerinde çalışır; arama sunucu tarafında isim başlangıcına
/// göre ayrı bir sorgu yapar (telefon/isim-ortası araması artık desteklenmiyor
/// — pagination'a geçişin bilinen kısıtı).
class AdminMemberListPanel extends ConsumerStatefulWidget {
  const AdminMemberListPanel({super.key});

  @override
  ConsumerState<AdminMemberListPanel> createState() =>
      _AdminMemberListPanelState();
}

class _AdminMemberListPanelState extends ConsumerState<AdminMemberListPanel> {
  _MemberFilter _filter = _MemberFilter.all;
  Timer? _searchDebounceTimer;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(adminMemberListControllerProvider);
    final controller = ref.read(adminMemberListControllerProvider.notifier);
    final isSearchActive = state.searchResults != null;
    final source = state.searchResults ?? state.items;
    final filtered = source.where(_matchesFilter).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenEdge,
                AppSpacing.lg,
                AppSpacing.screenEdge,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref.watch(
                          rcTextProvider(RemoteConfigKeys.membersListTitle),
                        ),
                        style: typography.headingLarge.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      Material(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          onTap: () {
                            ref
                                .read(newMemberControllerProvider.notifier)
                                .reset();
                            ref
                                .read(panelStackControllerProvider.notifier)
                                .push(const MemberInfoPanel());
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            constraints: const BoxConstraints(minHeight: 40),
                            alignment: Alignment.center,
                            child: Text(
                              ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersAddMemberButton,
                                ),
                              ),
                              style: typography.headingSmall.copyWith(
                                fontSize: 14,
                                color: colors.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    constraints: const BoxConstraints(minHeight: 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.outline),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 18,
                          color: colors.onSurfaceMuted,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: TextField(
                            onChanged: _onSearchChanged,
                            style: typography.bodyLarge.copyWith(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersListSearchHint,
                                ),
                              ),
                              hintStyle: typography.bodyLarge.copyWith(
                                color: colors.onSurfaceMuted,
                                fontSize: 15,
                              ),
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
                        _FilterChip(
                          label: ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonTumuFilter),
                          ),
                          selected: _filter == _MemberFilter.all,
                          onTap: () =>
                              setState(() => _filter = _MemberFilter.all),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersFilterActive,
                            ),
                          ),
                          selected: _filter == _MemberFilter.active,
                          onTap: () =>
                              setState(() => _filter = _MemberFilter.active),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.membersFilterExpiring,
                            ),
                          ),
                          selected: _filter == _MemberFilter.endingSoon,
                          onTap: () => setState(
                            () => _filter = _MemberFilter.endingSoon,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _FilterChip(
                          label: ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.commonPaketiYokFilter,
                            ),
                          ),
                          selected: _filter == _MemberFilter.none,
                          onTap: () =>
                              setState(() => _filter = _MemberFilter.none),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.sm,
                  AppSpacing.screenEdge,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: typography.bodyMedium.copyWith(
                          color: colors.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.refresh,
                      child: Text(
                        ref.watch(
                          rcTextProvider(RemoteConfigKeys.authRetryButton),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                  ? Center(
                      child: Text(
                        state.errorMessage != null
                            ? ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersListLoadError,
                                ),
                              )
                            : ref.watch(
                                rcTextProvider(
                                  RemoteConfigKeys.membersListEmptyState,
                                ),
                              ),
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: controller.refresh,
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          if (!isSearchActive &&
                              notification.metrics.maxScrollExtent -
                                      notification.metrics.pixels <
                                  _loadMoreThreshold) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.screenEdge,
                            AppSpacing.md,
                            AppSpacing.screenEdge,
                            AppSpacing.lg,
                          ),
                          itemCount:
                              filtered.length +
                              (!isSearchActive && state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= filtered.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _MemberCard(member: filtered[index]);
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(_searchDebounce, () {
      ref.read(adminMemberListControllerProvider.notifier).search(value);
    });
  }

  bool _matchesFilter(AdminMemberSummary member) {
    return switch (_filter) {
      _MemberFilter.all => true,
      _MemberFilter.active => member.status == MemberPackageStatus.active,
      _MemberFilter.endingSoon =>
        member.status == MemberPackageStatus.endingSoon,
      _MemberFilter.none => member.status == MemberPackageStatus.none,
    };
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          constraints: const BoxConstraints(minHeight: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: selected ? colors.primary : colors.outlineStrong,
            ),
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

class _MemberCard extends ConsumerWidget {
  const _MemberCard({required this.member});

  final AdminMemberSummary member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final (chipBg, chipFg) = switch (member.status) {
      MemberPackageStatus.active => (
        colors.successContainer,
        colors.onSuccessContainer,
      ),
      MemberPackageStatus.endingSoon => (
        colors.warningContainer,
        colors.onWarningContainer,
      ),
      MemberPackageStatus.none => (
        colors.errorContainer,
        colors.onErrorContainer,
      ),
    };
    final leftColor = member.status == MemberPackageStatus.none
        ? colors.error
        : (member.status == MemberPackageStatus.endingSoon
              ? colors.onWarningContainer
              : colors.onSurface);

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      onTap: () => ref
          .read(panelStackControllerProvider.notifier)
          .push(AdminMemberDetailPanel(memberId: member.id)),
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
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    member.initials,
                    style: typography.headingSmall.copyWith(
                      color: colors.onPrimaryContainer,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: typography.headingSmall.copyWith(
                          color: colors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        member.trainerName,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurfaceMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    ref.watch(
                      rcTextProvider(switch (member.status) {
                        MemberPackageStatus.active =>
                          RemoteConfigKeys.membersFilterActive,
                        MemberPackageStatus.endingSoon =>
                          RemoteConfigKeys.membersFilterExpiring,
                        MemberPackageStatus.none =>
                          RemoteConfigKeys.commonPaketiYokFilter,
                      }),
                    ),
                    style: typography.caption.copyWith(
                      color: chipFg,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.commonKalanDersLabel,
                            ),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${member.remainingSessions}',
                          style: typography.headingSmall.copyWith(
                            color: leftColor,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          ref.watch(
                            rcTextProvider(RemoteConfigKeys.commonBitisLabel),
                          ),
                          style: typography.caption.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          member.packageEndDate,
                          style: typography.headingSmall.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
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
