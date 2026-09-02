import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/expense_category.dart';
import '../domain/expense_state.dart';
import '../repository/expenses_repository.dart';
import '../../../shared/utils/date_labels.dart';

part 'expenses_controller.g.dart';

const _empty = ExpensesState(
  monthLabel: '',
  revenueRatioLabel: '—',
  entries: [],
);

/// Finans panelinde görüntülenen ay (ayın ilk günü). Varsayılan: içinde
/// bulunulan ay. Önceden gider listesi `DateTime.now()`'a sabitliydi, yani
/// ay değişince bir önceki ayın girdileri hiç görülemiyordu (kullanıcı
/// raporu, 2026-09-02).
///
/// İleri gitmek içinde bulunulan ayla SINIRLI — gider tarihleri geleceğe
/// girilebilse de, kullanıcıyı boş aylarda sonsuza kadar ilerletmenin bir
/// faydası yok; [canGoNext] bunu panelde butonu pasifleştirmek için açar.
@riverpod
class ExpensesSelectedMonth extends _$ExpensesSelectedMonth {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void previous() => state = DateTime(state.year, state.month - 1);

  void next() {
    if (!expensesMonthIsBeforeCurrent(state)) return;
    state = DateTime(state.year, state.month + 1);
  }
}

/// Saf yardımcı — [expensesCanGoNextMonth] ve [ExpensesSelectedMonth.next]
/// aynı kuralı paylaşsın diye ayrıldı (test edilebilir).
bool expensesMonthIsBeforeCurrent(DateTime month) {
  final now = DateTime.now();
  return month.isBefore(DateTime(now.year, now.month));
}

/// Panelde "sonraki ay" okunu pasifleştirmek için — `notifier`'ı `watch`
/// etmek yeniden çizim TETİKLEMEZ (state değişimini dinlemez), bu yüzden
/// türetilmiş bir provider olarak duruyor.
@riverpod
bool expensesCanGoNextMonth(ExpensesCanGoNextMonthRef ref) {
  return expensesMonthIsBeforeCurrent(ref.watch(expensesSelectedMonthProvider));
}

@riverpod
Stream<ExpensesState> _expensesForGym(
  _ExpensesForGymRef ref,
  String gymId,
  DateTime month,
) {
  return ref
      .watch(expensesRepositoryProvider)
      .watchMonth(gymId, month, ref.watch(dateLabelsProvider));
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
    final month = ref.watch(expensesSelectedMonthProvider);
    return ref.watch(_expensesForGymProvider(gymId, month)).valueOrNull ??
        _empty;
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
