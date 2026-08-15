import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/expense_state.dart';
import '../service/expenses_service.dart';

part 'expenses_repository.g.dart';

abstract interface class ExpensesRepository {
  Stream<ExpensesState> watchMonth(String gymId);
  Future<void> addExpense({
    required String gymId,
    required String category,
    required String title,
    required DateTime date,
    required int amountTl,
    required bool recurring,
  });
}

class ExpensesRepositoryImpl implements ExpensesRepository {
  const ExpensesRepositoryImpl(this._service);

  final ExpensesService _service;

  @override
  Stream<ExpensesState> watchMonth(String gymId) => _service.watchMonth(gymId);

  @override
  Future<void> addExpense({
    required String gymId,
    required String category,
    required String title,
    required DateTime date,
    required int amountTl,
    required bool recurring,
  }) {
    return _service.addExpense(
      gymId: gymId,
      category: category,
      title: title,
      date: date,
      amountTl: amountTl,
      recurring: recurring,
    );
  }
}

@riverpod
ExpensesRepository expensesRepository(ExpensesRepositoryRef ref) {
  return ExpensesRepositoryImpl(ref.watch(expensesServiceProvider));
}
