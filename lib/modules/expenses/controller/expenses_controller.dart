import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/expense_state.dart';
import '../repository/expenses_repository.dart';

part 'expenses_controller.g.dart';

@riverpod
class ExpensesController extends _$ExpensesController {
  @override
  ExpensesState build() => ref.watch(expensesRepositoryProvider).loadInitial();

  void addExpense(ExpenseEntry entry) => state = state.copyWith(entries: [entry, ...state.entries]);
}
