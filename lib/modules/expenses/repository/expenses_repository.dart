import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/expense_state.dart';
import '../service/expenses_service.dart';

part 'expenses_repository.g.dart';

abstract interface class ExpensesRepository {
  ExpensesState loadInitial();
}

class ExpensesRepositoryImpl implements ExpensesRepository {
  const ExpensesRepositoryImpl(this._service);

  final ExpensesService _service;

  @override
  ExpensesState loadInitial() => _service.loadInitial();
}

@riverpod
ExpensesRepository expensesRepository(ExpensesRepositoryRef ref) {
  return ExpensesRepositoryImpl(ref.watch(expensesServiceProvider));
}
