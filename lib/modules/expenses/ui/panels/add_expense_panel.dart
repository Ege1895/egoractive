import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/money/app_money_formatter.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/remote_config/remote_config_service.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/tr_date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/native_date_picker.dart';
import '../../controller/expenses_controller.dart';
import '../../domain/expense_category.dart';

/// Admin 15 · Gider Ekle — kategori, tutar, tarih, tekrar. Kategori listesi
/// Remote Config'ten (`cfg_expense_categories`) okunur — yeni bir kategori
/// eklemek kod değişikliği gerektirmiyor (F5-3 kabul kriteri).
class AddExpensePanel extends BasePanel {
  const AddExpensePanel({super.key});

  @override
  ConsumerState<AddExpensePanel> createState() => _AddExpensePanelState();
}

class _AddExpensePanelState extends BasePanelState<AddExpensePanel> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _titleScrollController = ScrollController();
  DateTime _date = DateTime.now();
  String? _category;
  bool _recurring = false;
  bool _isSaving = false;
  String? _amountError;
  String? _titleError;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final categories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];
    _category ??= categories.isEmpty ? null : categories.first.id;
    final selectedMatches = categories.where((c) => c.id == _category);
    final selectedLabel = selectedMatches.isEmpty
        ? null
        : selectedMatches.first.label;

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
                        rcTextProvider(RemoteConfigKeys.expensesAddTitle),
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
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusCard,
                      ),
                      border: Border.all(color: colors.outline),
                    ),
                    child: AppTextField(
                      label: ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.expensesAmountFieldLabel,
                        ),
                      ),
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        AppMoneyInputFormatter(
                          locale: ref.watch(localeControllerProvider),
                        ),
                      ],
                      hint: ref.watch(
                        rcTextProvider(
                          RemoteConfigKeys.expensesAmountFieldHint,
                        ),
                      ),
                      errorText: _amountError,
                      onChanged: (_) {
                        if (_amountError != null) {
                          setState(() => _amountError = null);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.expensesCategoryFieldLabel,
                      ),
                    ),
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusInner),
                    onTap: categories.isEmpty
                        ? null
                        : () => _showCategoryPicker(context, categories),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusInner,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedLabel ??
                                  ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .expensesCategoryPickerTitle,
                                    ),
                                  ),
                              style: typography.bodyLarge.copyWith(
                                color: selectedLabel == null
                                    ? colors.onSurfaceMuted
                                    : colors.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: colors.onSurfaceMuted,
                            size: 18,
                          ),
                        ],
                      ),
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
                                RemoteConfigKeys.expensesDescriptionFieldLabel,
                              ),
                            ),
                            controller: _titleController,
                            scrollController: _titleScrollController,
                            minLines: 1,
                            maxLines: 5,
                            hint: ref.watch(
                              rcTextProvider(
                                RemoteConfigKeys.expensesDescriptionFieldHint,
                              ),
                            ),
                            errorText: _titleError,
                            onChanged: (_) {
                              if (_titleError != null) {
                                setState(() => _titleError = null);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusInner,
                          ),
                          onTap: () => showNativeDatePicker(
                            context: context,
                            initial: _date,
                            firstDate: DateTime(DateTime.now().year - 5),
                            lastDate: DateTime(DateTime.now().year + 1),
                            onSelected: (date) => setState(() => _date = date),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceRaised,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusInner,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ref.watch(
                                          rcTextProvider(
                                            RemoteConfigKeys
                                                .expensesDateFieldLabel,
                                          ),
                                        ),
                                        style: typography.caption.copyWith(
                                          color: colors.onSurfaceMuted,
                                        ),
                                      ),
                                      Text(
                                        formatTrDate(_date),
                                        style: typography.bodyLarge.copyWith(
                                          color: colors.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: colors.onSurfaceMuted,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 66),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .expensesRecurringToggleLabel,
                                    ),
                                  ),
                                  style: typography.bodyLarge.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  ref.watch(
                                    rcTextProvider(
                                      RemoteConfigKeys
                                          .expensesRecurringToggleDescription,
                                    ),
                                  ),
                                  style: typography.caption.copyWith(
                                    color: colors.onSurfaceMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _recurring = !_recurring),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 52,
                              height: 32,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: _recurring
                                    ? colors.primary
                                    : colors.surfaceRaised,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              alignment: _recurring
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: colors.onSurface,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    ref.watch(
                      rcTextProvider(
                        RemoteConfigKeys.expensesTrainerCommissionNote,
                      ),
                    ),
                    style: typography.caption.copyWith(
                      color: colors.onSurfaceMuted,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: _isSaving
                        ? ref.watch(
                            rcTextProvider(RemoteConfigKeys.membersSavingLabel),
                          )
                        : ref.watch(
                            rcTextProvider(
                              RemoteConfigKeys.expensesSubmitButton,
                            ),
                          ),
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final amount = parseMoneyInput(
                              _amountController.text,
                              ref.read(localeControllerProvider),
                            );
                            final title = _titleController.text.trim();
                            final category = _category;
                            var hasError = false;
                            if (amount <= 0) {
                              setState(
                                () => _amountError = ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys.expensesAmountInvalidError,
                                  ),
                                ),
                              );
                              hasError = true;
                            }
                            if (title.isEmpty) {
                              setState(
                                () => _titleError = ref.read(
                                  rcTextProvider(
                                    RemoteConfigKeys
                                        .expensesDescriptionRequiredError,
                                  ),
                                ),
                              );
                              hasError = true;
                            }
                            if (hasError) return;
                            if (!await ensureSubscriptionAllowsWrite(
                              context,
                              ref,
                            )) {
                              return;
                            }

                            setState(() {
                              _isSaving = true;
                              _errorMessage = null;
                            });
                            try {
                              await ref
                                  .read(expensesControllerProvider.notifier)
                                  .addExpense(
                                    category: category!,
                                    title: title,
                                    date: _date,
                                    amountTl: amount,
                                    recurring: _recurring,
                                  );
                              if (mounted) {
                                ref
                                    .read(panelStackControllerProvider.notifier)
                                    .pop();
                              }
                            } catch (_) {
                              if (mounted) {
                                setState(() {
                                  _isSaving = false;
                                  _errorMessage = ref.read(
                                    rcTextProvider(
                                      RemoteConfigKeys.expensesSaveFailedError,
                                    ),
                                  );
                                });
                              }
                            }
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    List<ExpenseCategoryOption> categories,
  ) {
    final colors = context.appColors;
    final typography = context.appTypography;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
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
                      RemoteConfigKeys.expensesCategoryPickerTitle,
                    ),
                  ),
                  style: typography.headingMedium.copyWith(
                    color: colors.onSurface,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (final category in categories)
                  InkWell(
                    onTap: () {
                      setState(() => _category = category.id);
                      Navigator.of(sheetContext).pop();
                    },
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 52),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.label,
                              style: typography.bodyLarge.copyWith(
                                color: colors.onSurface,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (category.id == _category)
                            Icon(Icons.check, size: 18, color: colors.primary),
                        ],
                      ),
                    ),
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
    _amountController.dispose();
    _titleController.dispose();
    _titleScrollController.dispose();
    super.dispose();
  }
}
