import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/expense_state.dart';
import '../repository/expenses_repository.dart';

part 'expenses_controller.g.dart';

const _empty = ExpensesState(monthLabel: '', revenueRatioLabel: '—', entries: []);

@riverpod
Stream<ExpensesState> _expensesForGym(_ExpensesForGymRef ref, String gymId) {
  return ref.watch(expensesRepositoryProvider).watchMonth(gymId);
}

/// F5-3 — `cfg_expense_categories` okuması burada async-wrapped: Remote
/// Config henüz hazır olmadığı (ör. Firebase başlatılmamış test ortamı)
/// durumlarda panel çökmesin diye.
@riverpod
Stream<List<String>> expenseCategories(ExpenseCategoriesRef ref) async* {
  yield ref.watch(remoteConfigServiceProvider).expenseCategories;
}

@riverpod
class ExpensesController extends _$ExpensesController {
  @override
  ExpensesState build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return _empty;
    return ref.watch(_expensesForGymProvider(gymId)).valueOrNull ?? _empty;
  }

  Future<void> addExpense({
    required String category,
    required String title,
    required DateTime date,
    required int amountTl,
    required bool recurring,
  }) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await ref.read(expensesRepositoryProvider).addExpense(
          gymId: gymId,
          category: category,
          title: title,
          date: date,
          amountTl: amountTl,
          recurring: recurring,
        );
  }
}
