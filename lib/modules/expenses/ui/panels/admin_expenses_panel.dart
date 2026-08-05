import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
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
    final maxCategory = state.categoryTotals.isEmpty ? 1 : state.categoryTotals.first.amountTl;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.lg, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Giderler', style: typography.headingLarge.copyWith(color: colors.onSurface))),
                  Material(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                      onTap: () => ref.read(panelStackControllerProvider.notifier).push(const AddExpensePanel()),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        constraints: const BoxConstraints(minHeight: 40),
                        alignment: Alignment.center,
                        child: Text('+ Gider', style: typography.headingSmall.copyWith(fontSize: 14, color: colors.onPrimary)),
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${state.monthLabel} toplam gider', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('₺${state.totalTl}', style: typography.dataLarge.copyWith(color: colors.onSurface, fontSize: 34)),
                        const SizedBox(height: AppSpacing.xs),
                        Text('Ciroya oranı ${state.revenueRatioLabel}', style: typography.bodyMedium.copyWith(color: colors.onSurfaceVariant, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('KATEGORİLER', style: typography.caption.copyWith(color: colors.onSurfaceMuted, letterSpacing: 1.2)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      children: [
                        for (var i = 0; i < state.categoryTotals.length; i++) ...[
                          _CategoryRow(total: state.categoryTotals[i], ratio: state.categoryTotals[i].amountTl / maxCategory),
                          if (i < state.categoryTotals.length - 1) const SizedBox(height: AppSpacing.md),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('SON KAYITLAR', style: typography.caption.copyWith(color: colors.onSurfaceMuted, letterSpacing: 1.2)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      children: [
                        for (var i = 0; i < state.entries.length; i++) _ExpenseRow(entry: state.entries[i], showDivider: i < state.entries.length - 1),
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
  const _CategoryRow({required this.total, required this.ratio});

  final ExpenseCategoryTotal total;
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
            Expanded(child: Text(total.category, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15))),
            Text('₺${total.amountTl}', style: typography.headingSmall.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          child: LinearProgressIndicator(value: ratio.clamp(0, 1), minHeight: 8, backgroundColor: colors.surfaceRaised, valueColor: AlwaysStoppedAnimation(colors.primary)),
        ),
      ],
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({required this.entry, required this.showDivider});

  final ExpenseEntry entry;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: BoxDecoration(border: showDivider ? Border(bottom: BorderSide(color: colors.outline)) : null),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title, style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                Text('${entry.category} · ${entry.date}', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
              ],
            ),
          ),
          Text('₺${entry.amountTl}', style: typography.headingSmall.copyWith(color: colors.onSurfaceVariant, fontSize: 15)),
        ],
      ),
    );
  }
}
