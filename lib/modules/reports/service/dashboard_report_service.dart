import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';

part 'dashboard_report_service.g.dart';

const _monthNamesLong = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};

/// F5-1 — büyük veri setlerinde (10.000+ seans) dashboard'ı hızlı tutmak
/// için hiçbir yerde tüm dokümanlar client'a çekilmiyor: sayımlar Firestore
/// `count()`/`sum()` aggregation query'leriyle sunucu tarafında hesaplanıyor.
class DashboardReportService {
  const DashboardReportService();

  Future<DashboardReport> loadReport(String gymId) async {
    final now = DateTime.now();
    final monthStart = Timestamp.fromDate(DateTime(now.year, now.month, 1));

    final monthSessions = FirebaseFirestore.instance
        .collection('sessions')
        .where('gymId', isEqualTo: gymId)
        .where('startTime', isGreaterThanOrEqualTo: monthStart);

    final trainersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .where('role', isEqualTo: 'trainer')
        .get();

    final results = await Future.wait([
      monthSessions.count().get(),
      monthSessions.where('status', isEqualTo: 'completed').count().get(),
      monthSessions.where('status', isEqualTo: 'cancelled').count().get(),
      FirebaseFirestore.instance
          .collection('memberPackages')
          .where('gymId', isEqualTo: gymId)
          .where('purchasedAt', isGreaterThanOrEqualTo: monthStart)
          .aggregate(sum('paidAmount'))
          .get(),
      FirebaseFirestore.instance
          .collection('expenses')
          .where('gymId', isEqualTo: gymId)
          .where('date', isGreaterThanOrEqualTo: monthStart)
          .aggregate(sum('amountTl'))
          .get(),
      ...trainersSnapshot.docs.expand((trainer) => [
            monthSessions.where('trainerId', isEqualTo: trainer.id).count().get(),
            monthSessions.where('trainerId', isEqualTo: trainer.id).where('status', isEqualTo: 'completed').count().get(),
          ]),
    ]);

    final totalSessions = results[0].count ?? 0;
    final completedSessions = results[1].count ?? 0;
    final cancelledSessions = results[2].count ?? 0;
    final estimatedRevenueTl = (results[3].getSum('paidAmount') ?? 0).round();
    final totalExpensesTl = (results[4].getSum('amountTl') ?? 0).round();

    final trainerPerformance = <TrainerPerformance>[];
    for (var i = 0; i < trainersSnapshot.docs.length; i++) {
      final trainer = trainersSnapshot.docs[i];
      final total = results[5 + i * 2].count ?? 0;
      final completed = results[6 + i * 2].count ?? 0;
      trainerPerformance.add(TrainerPerformance(
        trainerId: trainer.id,
        name: (trainer.data()['name'] as String?) ?? '—',
        completedSessions: completed,
        totalSessions: total,
      ));
    }
    trainerPerformance.sort((a, b) => b.completedSessions.compareTo(a.completedSessions));

    return DashboardReport(
      monthLabel: '${_monthNamesLong[now.month]} ${now.year} özeti',
      totalSessions: totalSessions,
      completedSessions: completedSessions,
      cancelledSessions: cancelledSessions,
      trainerPerformance: trainerPerformance,
      estimatedRevenueTl: estimatedRevenueTl,
      totalExpensesTl: totalExpensesTl,
    );
  }
}

@riverpod
DashboardReportService dashboardReportService(DashboardReportServiceRef ref) => const DashboardReportService();
