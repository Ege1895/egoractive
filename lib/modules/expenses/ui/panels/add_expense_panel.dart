import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/panels/base_panel.dart';
import '../../../../core/panels/panel_stack_controller.dart';
import '../../../../core/subscription/subscription_write_gate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/utils/tr_date_formatter.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../controller/expenses_controller.dart';

const _monthAbbrevToNumber = {
  'Oca': 1,
  'Şub': 2,
  'Mar': 3,
  'Nis': 4,
  'May': 5,
  'Haz': 6,
  'Tem': 7,
  'Ağu': 8,
  'Eyl': 9,
  'Eki': 10,
  'Kas': 11,
  'Ara': 12,
};

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
  final _dateController = TextEditingController(
    text: formatTrDate(DateTime.now()),
  );
  String? _category;
  bool _recurring = false;
  bool _isSaving = false;
  String? _amountError;
  String? _titleError;
  String? _dateError;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final typography = context.appTypography;
    final categories =
        ref.watch(expenseCategoriesProvider).valueOrNull ?? const [];
    _category ??= categories.isEmpty ? null : categories.first.id;

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
                      'Gider ekle',
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
                      'Vazgeç',
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
                      label: 'Tutar (₺)',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      hint: '8400',
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
                    'Kategori',
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurfaceMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final category in categories)
                        _CategoryChip(
                          label: category.label,
                          selected: _category == category.id,
                          onTap: () => setState(() => _category = category.id),
                        ),
                    ],
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
                        AppTextField(
                          label: 'Açıklama',
                          controller: _titleController,
                          hint: 'Reformer yay değişimi',
                          errorText: _titleError,
                          onChanged: (_) {
                            if (_titleError != null) {
                              setState(() => _titleError = null);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Tarih',
                          controller: _dateController,
                          errorText: _dateError,
                          onChanged: (_) {
                            if (_dateError != null) {
                              setState(() => _dateError = null);
                            }
                          },
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
                                  'Her ay tekrar et',
                                  style: typography.bodyLarge.copyWith(
                                    color: colors.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Kira ve fatura gibi sabit giderler için',
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
                    'Antrenör primleri seans onaylarından otomatik hesaplanır; buraya elle girilmez.',
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
                    label: _isSaving ? 'Kaydediliyor…' : 'Gideri kaydet',
                    onPressed: _isSaving
                        ? null
                        : () async {
                            final amount =
                                int.tryParse(_amountController.text) ?? 0;
                            final title = _titleController.text.trim();
                            final category = _category;
                            final date = _parseDate(_dateController.text);
                            var hasError = false;
                            if (amount <= 0) {
                              setState(
                                () => _amountError = 'Geçerli bir tutar gir.',
                              );
                              hasError = true;
                            }
                            if (title.isEmpty) {
                              setState(
                                () => _titleError = 'Açıklama boş bırakılamaz.',
                              );
                              hasError = true;
                            }
                            if (date == null) {
                              setState(
                                () => _dateError =
                                    'Tarihi "gün ay yıl" formatında gir (örn. 18 Tem 2026).',
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
                                    date: date!,
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
                                  _errorMessage =
                                      'Gider kaydedilemedi, tekrar dene.';
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

  /// "18 Tem 2026" formatını ayrıştırır — geçersizse null.
  DateTime? _parseDate(String text) {
    final parts = text.trim().split(RegExp(r'\s+'));
    if (parts.length != 3) return null;
    final day = int.tryParse(parts[0]);
    final month = _monthAbbrevToNumber[parts[1]];
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;
    return DateTime(year, month, day);
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
  const _CategoryChip({
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
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13),
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
