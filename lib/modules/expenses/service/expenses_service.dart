import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/expense_state.dart';

part 'expenses_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}/expenses` koleksiyonuna
/// bağlanacak. Antrenör primleri seans onaylarından otomatik hesaplanır,
/// elle girilmez.
class ExpensesService {
  const ExpensesService();

  ExpensesState loadInitial() {
    return const ExpensesState(
      monthLabel: 'Temmuz 2026',
      revenueRatioLabel: '%37',
      entries: [
        ExpenseEntry(id: 'kira-temmuz', category: 'Kira', title: 'Stüdyo kirası', date: '1 Tem 2026', amountTl: 65000, recurring: true),
        ExpenseEntry(id: 'prim-temmuz', category: 'Prim', title: 'Antrenör primleri', date: '31 Tem 2026', amountTl: 42000),
        ExpenseEntry(id: 'fatura-elektrik', category: 'Fatura', title: 'Elektrik faturası', date: '22 Tem 2026', amountTl: 8600, recurring: true),
        ExpenseEntry(id: 'ekipman-reformer', category: 'Ekipman', title: 'Reformer yay değişimi', date: '18 Tem 2026', amountTl: 8400),
        ExpenseEntry(id: 'pazarlama-instagram', category: 'Pazarlama', title: 'Instagram reklamı', date: '12 Tem 2026', amountTl: 6800),
        ExpenseEntry(id: 'diger-temizlik', category: 'Diğer', title: 'Temizlik malzemesi', date: '5 Tem 2026', amountTl: 12000),
      ],
    );
  }
}

@riverpod
ExpensesService expensesService(ExpensesServiceRef ref) => const ExpensesService();
