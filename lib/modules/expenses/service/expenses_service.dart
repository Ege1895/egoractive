import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/expense_state.dart';

part 'expenses_service.g.dart';

const _monthNamesLong = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};
const _monthAbbrev = {
  1: 'Oca', 2: 'Şub', 3: 'Mar', 4: 'Nis', 5: 'May', 6: 'Haz',
  7: 'Tem', 8: 'Ağu', 9: 'Eyl', 10: 'Eki', 11: 'Kas', 12: 'Ara',
};

/// F5-3 — `expenses` koleksiyonu (gymId, category, title, date, amountTl,
/// recurring). Antrenör primleri seans onaylarından otomatik hesaplanır,
/// buraya elle girilmez — o yüzden burada sadece admin'in girdiği giderler var.
class ExpensesService {
  const ExpensesService();

  Stream<ExpensesState> watchMonth(String gymId) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1);

    return FirebaseFirestore.instance
        .collection('expenses')
        .where('gymId', isEqualTo: gymId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('date', isLessThan: Timestamp.fromDate(monthEnd))
        .snapshots()
        .asyncMap((snapshot) async {
      final docs = snapshot.docs.toList()
        ..sort((a, b) => (b.data()['date'] as Timestamp).compareTo(a.data()['date'] as Timestamp));
      final entries = docs.map(_toEntry).toList();
      final revenueRatioLabel = await _revenueRatioLabel(gymId, monthStart, monthEnd, entries);
      return ExpensesState(
        monthLabel: '${_monthNamesLong[now.month]} ${now.year}',
        revenueRatioLabel: revenueRatioLabel,
        entries: entries,
      );
    });
  }

  Future<void> addExpense({
    required String gymId,
    required String category,
    required String title,
    required DateTime date,
    required int amountTl,
    required bool recurring,
  }) {
    return FirebaseFirestore.instance.collection('expenses').add({
      'gymId': gymId,
      'category': category,
      'title': title,
      'date': Timestamp.fromDate(date),
      'amountTl': amountTl,
      'recurring': recurring,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  ExpenseEntry _toEntry(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final date = (data['date'] as Timestamp).toDate();
    return ExpenseEntry(
      id: doc.id,
      category: (data['category'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      date: '${date.day} ${_monthAbbrev[date.month]} ${date.year}',
      amountTl: (data['amountTl'] as num?)?.toInt() ?? 0,
      recurring: (data['recurring'] as bool?) ?? false,
    );
  }

  /// F5-1'deki dashboard ile aynı yaklaşım: ciro `memberPackages.paidAmount`
  /// aggregation'ından, tek bir sum() sorgusuyla.
  Future<String> _revenueRatioLabel(String gymId, DateTime monthStart, DateTime monthEnd, List<ExpenseEntry> entries) async {
    final totalTl = entries.fold<int>(0, (total, e) => total + e.amountTl);
    final revenueSnapshot = await FirebaseFirestore.instance
        .collection('memberPackages')
        .where('gymId', isEqualTo: gymId)
        .where('purchasedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .where('purchasedAt', isLessThan: Timestamp.fromDate(monthEnd))
        .aggregate(sum('paidAmount'))
        .get();
    final revenueTl = (revenueSnapshot.getSum('paidAmount') ?? 0).round();
    if (revenueTl <= 0) return '—';
    return '%${((totalTl / revenueTl) * 100).round()}';
  }
}

@riverpod
ExpensesService expensesService(ExpensesServiceRef ref) => const ExpensesService();
