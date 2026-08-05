import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/expenses_controller.dart';
import '../../domain/expense_category.dart';
import '../../domain/expense_state.dart';

/// Admin 15 · Gider Ekle — kategori, tutar, tarih, tekrar.
class AddExpensePanel extends BasePanel {
  const AddExpensePanel({super.key});

  @override
  ConsumerState<AddExpensePanel> createState() => _AddExpensePanelState();
}

class _AddExpensePanelState extends BasePanelState<AddExpensePanel> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController(text: '18 Tem 2026');
  String _category = expenseCategoryOptions.first;
  bool _recurring = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, 0),
              child: Row(
                children: [
                  Expanded(child: Text('Gider ekle', style: typography.headingSmall.copyWith(color: colors.onSurface, fontSize: 18))),
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: AppTextField(label: 'Tutar (₺)', controller: _amountController, keyboardType: TextInputType.number, hint: '8400'),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Kategori', style: typography.bodyMedium.copyWith(color: colors.onSurfaceMuted, fontSize: 13)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final category in expenseCategoryOptions)
                        _CategoryChip(label: category, selected: _category == category, onTap: () => setState(() => _category = category)),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(label: 'Açıklama', controller: _titleController, hint: 'Reformer yay değişimi'),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(label: 'Tarih', controller: _dateController),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(AppSpacing.radiusCard), border: Border.all(color: colors.outline)),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 66),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Her ay tekrar et', style: typography.bodyLarge.copyWith(color: colors.onSurface, fontSize: 15)),
                                Text('Kira ve fatura gibi sabit giderler için', style: typography.caption.copyWith(color: colors.onSurfaceMuted)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _recurring = !_recurring),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 52,
                              height: 32,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(color: _recurring ? colors.primary : colors.surfaceRaised, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                              alignment: _recurring ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(width: 26, height: 26, decoration: BoxDecoration(color: colors.onSurface, shape: BoxShape.circle)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Antrenör primleri seans onaylarından otomatik hesaplanır; buraya elle girilmez.',
                    style: typography.caption.copyWith(color: colors.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenEdge, AppSpacing.md, AppSpacing.screenEdge, AppSpacing.lg),
              child: AppButton(
                label: 'Gideri kaydet',
                onPressed: () {
                  final amount = int.tryParse(_amountController.text) ?? 0;
                  final title = _titleController.text.trim();
                  if (amount <= 0 || title.isEmpty) return;
                  ref.read(expensesControllerProvider.notifier).addExpense(
                        ExpenseEntry(
                          id: '${title.toLowerCase().replaceAll(' ', '-')}-${DateTime.now().millisecondsSinceEpoch}',
                          category: _category,
                          title: title,
                          date: _dateController.text.trim(),
                          amountTl: amount,
                          recurring: _recurring,
                        ),
                      );
                  ref.read(panelStackControllerProvider.notifier).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: selected ? colors.primary : colors.surfaceRaised,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          constraints: const BoxConstraints(minHeight: 34),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusPill), border: Border.all(color: selected ? colors.primary : colors.outlineStrong)),
          child: Text(label, style: context.appTypography.headingSmall.copyWith(fontSize: 14, color: selected ? colors.onPrimary : colors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
