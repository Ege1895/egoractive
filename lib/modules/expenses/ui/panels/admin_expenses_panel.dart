import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/thousands_input_formatter.dart';
import '../../controller/expenses_controller.dart';
import '../../domain/expense_state.dart';
import 'add_expense_panel.dart';

/// Admin 14 · Giderler (Finans sekmesi kökü) — kategori bazlı gider listesi.
class AdminExpensesPanel extends ConsumerWidget {
  const AdminExpensesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final state = ref.watch(expensesControllerProvider);
    final maxCategory = state.categoryTotals.isEmpty
        ? 1
        : state.categoryTotals.first.amountTl;
    final categories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];
    final categoryLabels = {for (final c in categories) c.id: c.label};
    String labelFor(String id) => categoryLabels[id] ?? id;

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
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ref.watch(
                        rcTextProvider(RemoteConfigKeys.expensesListTitle),
                      ),
                      style: typography.headingLarge.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusInner,
                      ),
                      onTap: () => ref
                          .read(panelStackControllerProvider.notifier)
                          .push(const AddExpensePanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text(
                          ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.expensesAddExpenseButton,
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
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenEdge,
                  AppSpacing.md,
                  AppSpacing.screenEdge,
                  AppSpacing.lg,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
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
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys.expensesMonthlyTotalLabel,
                                ),
                              )
                              .replaceAll('{month}', state.monthLabel),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '₺${formatThousands(state.totalTl)}',
                          style: typography.dataLarge.copyWith(
                            color: colors.onSurface,
                            fontSize: 34,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ref
                              .watch(
                                rcTextProvider(
                                  RemoteConfigKeys.expensesRevenueRatioLabel,
                                ),
                              )
                              .replaceAll('{ratio}', state.revenueRatioLabel),
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.expensesCategoriesSectionHeader,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
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
                      children: [
                        for (
                          var i = 0;
                          i < state.categoryTotals.length;
                          i++
                        ) ...[
                          _CategoryRow(
                            total: state.categoryTotals[i],
                            label: labelFor(state.categoryTotals[i].category),
                            ratio:
                                state.categoryTotals[i].amountTl / maxCategory,
                          ),
                          if (i < state.categoryTotals.length - 1)
                            const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.expensesRecentEntriesSectionHeader,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
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
                        for (var i = 0; i < state.entries.length; i++)
                          _ExpenseRow(
                            entry: state.entries[i],
                            categoryLabel: labelFor(state.entries[i].category),
                            showDivider: i < state.entries.length - 1,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.total,
    required this.label,
    required this.ratio,
  });

  final ExpenseCategoryTotal total;
  final String label;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: typography.bodyLarge.copyWith(
                  color: colors.onSurface,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              '₺${formatThousands(total.amountTl)}',
              style: typography.headingSmall.copyWith(
                color: colors.onSurfaceVariant,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(
            value: ratio.clamp(0, 1),
            minHeight: 8,
            backgroundColor: colors.surfaceRaised,
            valueColor: AlwaysStoppedAnimation(colors.primary),
          ),
        ),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.entry,
    required this.categoryLabel,
    required this.showDivider,
  });

  final ExpenseEntry entry;
  final String categoryLabel;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: colors.outline))
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: typography.bodyLarge.copyWith(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$categoryLabel · ${entry.date}',
                  style: typography.caption.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₺${formatThousands(entry.amountTl)}',
            style: typography.headingSmall.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
