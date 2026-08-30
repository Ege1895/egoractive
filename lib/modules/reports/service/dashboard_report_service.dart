import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';

part 'dashboard_report_service.g.dart';

const _monthNamesLong = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};

/// F5-1/F7-2 — büyük veri setlerinde (10.000+ seans) dashboard'ı hızlı
/// tutmak için hiçbir yerde tüm dokümanlar client'a çekilmiyor: [loadSummary]
/// Firestore `count()`/`sum()` aggregation query'leriyle sunucu tarafında
/// hesaplanıyor. [loadTrainerPerformance] ise ESKİDEN antrenör başına 2
/// `count()` sorgusu yapıyordu (N antrenörde 2N round-trip; yük testinde
/// 20 antrenörlü bir salonda tek başına ~5 saniyeye çıktığı ölçüldü) — artık
/// bunun yerine her seans yazımında `functions/src/triggers/on-session-write-update-trainer-stats.ts`
/// trigger'ının canlı tuttuğu TEK bir özet dokümanı (`gyms/{gymId}/monthlyTrainerStats/{yearMonth}`)
/// okuyor: antrenör sayısından ve toplam seans hacminden tamamen bağımsız,
/// sabit maliyetli TEK bir okuma. [loadSummary]/[loadTrainerPerformance]
/// yine de ayrı metotlar — `DashboardReportController` özet metrikleri
/// antrenör dökümünü beklemeden gösterebilsin diye (bkz. controller'daki
/// iki ayrı provider).
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

  /// TEK doküman okuması — `stats` map'i zaten antrenör adını da taşıdığı
  /// için (trigger, seansın kendi denormalize `trainerName` alanından
  /// yazıyor) ayrıca bir `users` sorgusu de gerekmiyor. Bu ay hiç seansı
  /// olmayan bir antrenör kovada hiç yer almaz — "performans" listesinde
  /// zaten gösterecek bir şeyi yok, bu BİLEREK kabul edilen bir davranış
  /// (eski N+1 sorgulu sürüm onu 0/0 olarak gösteriyordu).
  Future<List<TrainerPerformance>> loadTrainerPerformance(String gymId) async {
    final yearMonth = _yearMonthUtc(DateTime.now().toUtc());
    final snapshot = await FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .collection('monthlyTrainerStats')
        .doc(yearMonth)
        .get();

    final stats = snapshot.data()?['stats'] as Map<String, dynamic>? ?? const {};
    final trainerPerformance = stats.entries.map((entry) {
      final trainerId = entry.key;
      final data = entry.value as Map<String, dynamic>? ?? const {};
      return TrainerPerformance(
        trainerId: trainerId,
        name: (data['name'] as String?) ?? '—',
        completedSessions: (data['completed'] as num?)?.toInt() ?? 0,
        totalSessions: (data['total'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    trainerPerformance.sort((a, b) => b.completedSessions.compareTo(a.completedSessions));
    return trainerPerformance;
  }

  /// `startTime`'ın UTC takvim ayı, "2026-08" formatında — trigger'ın
  /// (`on-session-write-update-trainer-stats.ts`'teki `yearMonthUtc`) yazdığı
  /// anahtarla BİLEREK aynı (UTC) kural; salon saat dilimine göre
  /// hesaplamak ikisi arasında gece yarısı civarı uyuşmazlık riski doğururdu.
  String _yearMonthUtc(DateTime utc) =>
      '${utc.year}-${utc.month.toString().padLeft(2, '0')}';

  Query<Map<String, dynamic>> _monthSessionsQuery(String gymId, Timestamp monthStart) {
    return FirebaseFirestore.instance
        .collection('sessions')
        .where('gymId', isEqualTo: gymId)
        .where('startTime', isGreaterThanOrEqualTo: monthStart);
  }
}

@riverpod
DashboardReportService dashboardReportService(DashboardReportServiceRef ref) => const DashboardReportService();
