import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';

part 'dashboard_report_service.g.dart';

const _monthNamesLong = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};

/// F5-1/F7-2 — büyük veri setlerinde (10.000+ seans) dashboard'ı hızlı
/// tutmak için hiçbir yerde tüm dokümanlar client'a çekilmiyor: sayımlar
/// Firestore `count()`/`sum()` aggregation query'leriyle sunucu tarafında
/// hesaplanıyor. [loadSummary] ve [loadTrainerPerformance] BİLEREK ayrı
/// metotlar: antrenör dökümü, antrenör başına 2 `count()` sorgusu
/// gerektirdiğinden (N antrenörde 2N round-trip) salon büyüdükçe asıl
/// maliyeti bu taşıyor — yük testinde (`scripts/measure_query_latency.ts`)
/// 20 antrenörlü bir salonda tek başına ~5 saniyeye çıktığı ölçüldü. Ayrı
/// tutulunca `DashboardReportController` özet metrikleri antrenör
/// dökümünü beklemeden gösterebiliyor (bkz. controller'daki iki ayrı
/// provider).
class DashboardReportService {
  const DashboardReportService();

  Future<DashboardSummary> loadSummary(String gymId) async {
    final now = DateTime.now();
    final monthStart = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    final monthSessions = _monthSessionsQuery(gymId, monthStart);

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
    ]);

    return DashboardSummary(
      monthLabel: '${_monthNamesLong[now.month]} ${now.year} özeti',
      totalSessions: results[0].count ?? 0,
      completedSessions: results[1].count ?? 0,
      cancelledSessions: results[2].count ?? 0,
      estimatedRevenueTl: (results[3].getSum('paidAmount') ?? 0).round(),
      totalExpensesTl: (results[4].getSum('amountTl') ?? 0).round(),
    );
  }

  Future<List<TrainerPerformance>> loadTrainerPerformance(String gymId) async {
    final now = DateTime.now();
    final monthStart = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    final monthSessions = _monthSessionsQuery(gymId, monthStart);

    final trainersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .where('role', isEqualTo: 'trainer')
        .get();

    final counts = await Future.wait(trainersSnapshot.docs.expand((trainer) => [
          monthSessions.where('trainerId', isEqualTo: trainer.id).count().get(),
          monthSessions.where('trainerId', isEqualTo: trainer.id).where('status', isEqualTo: 'completed').count().get(),
        ]));

    final trainerPerformance = <TrainerPerformance>[];
    for (var i = 0; i < trainersSnapshot.docs.length; i++) {
      final trainer = trainersSnapshot.docs[i];
      trainerPerformance.add(TrainerPerformance(
        trainerId: trainer.id,
        name: (trainer.data()['name'] as String?) ?? '—',
        completedSessions: counts[i * 2 + 1].count ?? 0,
        totalSessions: counts[i * 2].count ?? 0,
      ));
    }
    trainerPerformance.sort((a, b) => b.completedSessions.compareTo(a.completedSessions));
    return trainerPerformance;
  }

  Query<Map<String, dynamic>> _monthSessionsQuery(String gymId, Timestamp monthStart) {
    return FirebaseFirestore.instance
        .collection('sessions')
        .where('gymId', isEqualTo: gymId)
        .where('startTime', isGreaterThanOrEqualTo: monthStart);
  }
}

@riverpod
DashboardReportService dashboardReportService(DashboardReportServiceRef ref) => const DashboardReportService();
