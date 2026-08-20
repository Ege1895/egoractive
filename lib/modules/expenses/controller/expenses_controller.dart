import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/expense_category.dart';
import '../domain/expense_state.dart';
import '../repository/expenses_repository.dart';

part 'expenses_controller.g.dart';

const _empty = ExpensesState(
  monthLabel: '',
  revenueRatioLabel: '—',
  entries: [],
);

@riverpod
Stream<ExpensesState> _expensesForGym(_ExpensesForGymRef ref, String gymId) {
  return ref.watch(expensesRepositoryProvider).watchMonth(gymId);
}

/// F5-3 — `cfg_expense_categories` okuması burada async-wrapped: Remote
/// Config henüz hazır olmadığı (ör. Firebase başlatılmamış test ortamı)
/// durumlarda panel çökmesin diye. Cihaz diline göre `label_tr`/`label_en`
/// çözümlenir — Firestore'a yazılan `id` dilden bağımsız kalır.
@riverpod
Stream<List<ExpenseCategoryOption>> expenseCategories(
  ExpenseCategoriesRef ref,
) async* {
  final rc = ref.watch(remoteConfigServiceProvider);
  final locale = ref.watch(localeControllerProvider);
  yield rc.expenseCategories.map((raw) {
    final id = raw['id'] as String? ?? '';
    return ExpenseCategoryOption(
      id: id,
      label: (raw['label_$locale'] as String?) ?? id,
    );
  }).toList();
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
    await ref
        .read(expensesRepositoryProvider)
        .addExpense(
          gymId: gymId,
          category: category,
          title: title,
          date: date,
          amountTl: amountTl,
          recurring: recurring,
        );
  }
}
