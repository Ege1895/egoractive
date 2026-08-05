import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_state.freezed.dart';

@freezed
class ExpenseEntry with _$ExpenseEntry {
  const factory ExpenseEntry({
    required String id,
    required String category,
    required String title,
    required String date,
    required int amountTl,
    @Default(false) bool recurring,
  }) = _ExpenseEntry;
}

@freezed
class ExpenseCategoryTotal with _$ExpenseCategoryTotal {
  const factory ExpenseCategoryTotal({
    required String category,
    required int amountTl,
  }) = _ExpenseCategoryTotal;
}

@freezed
class ExpensesState with _$ExpensesState {
  const factory ExpensesState({
    required String monthLabel,
    required String revenueRatioLabel,
    required List<ExpenseEntry> entries,
  }) = _ExpensesState;

  const ExpensesState._();

  int get totalTl => entries.fold(0, (sum, e) => sum + e.amountTl);

  List<ExpenseCategoryTotal> get categoryTotals {
    final totals = <String, int>{};
    for (final entry in entries) {
      totals[entry.category] = (totals[entry.category] ?? 0) + entry.amountTl;
    }
    final result = totals.entries.map((e) => ExpenseCategoryTotal(category: e.key, amountTl: e.value)).toList();
    result.sort((a, b) => b.amountTl.compareTo(a.amountTl));
    return result;
  }
}
