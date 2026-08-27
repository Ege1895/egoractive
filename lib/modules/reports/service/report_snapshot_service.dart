import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';
import '../domain/report_snapshot.dart';

part 'report_snapshot_service.g.dart';

/// F5-9 — F5-7/F5-8'in scheduled fonksiyonlarının yazdığı
/// `gyms/{gymId}/reportSnapshots` koleksiyonunu okur. Canlı dashboard'ın
/// (`DashboardReportService`) aksine burada yeniden aggregation yapılmıyor —
/// veri zaten Cloud Functions tarafında hesaplanıp saklanmış durumda.
class ReportSnapshotService {
  const ReportSnapshotService();

  static const _maxSnapshots = 52;

  Future<List<ReportSnapshot>> loadSnapshots(
    String gymId,
    ReportPeriod period,
  ) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .collection('reportSnapshots')
        .where('period', isEqualTo: period.name)
        .orderBy('periodStart', descending: true)
        .limit(_maxSnapshots)
        .get();

    return querySnapshot.docs.map((doc) => _fromDoc(doc, period)).toList();
  }

  ReportSnapshot _fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    ReportPeriod period,
  ) {
    final data = doc.data();
    final trainerPerformanceRaw =
        data['trainerPerformance'] as List<dynamic>? ?? const [];
    final trainerPerformance = trainerPerformanceRaw.map((entry) {
      final trainer = entry as Map<String, dynamic>;
      return TrainerPerformance(
        trainerId: trainer['trainerId'] as String? ?? '',
        name: trainer['name'] as String? ?? '—',
        completedSessions: (trainer['completedSessions'] as num?)?.toInt() ?? 0,
        totalSessions: (trainer['totalSessions'] as num?)?.toInt() ?? 0,
        cancelledSessions: (trainer['cancelledSessions'] as num?)?.toInt() ?? 0,
      );
    }).toList();
    final packagesRaw = data['packages'] as List<dynamic>? ?? const [];
    final packages = packagesRaw.map((entry) {
      final map = entry as Map<String, dynamic>;
      return ReportPackageSale(
        packageName: map['packageName'] as String? ?? '—',
        count: (map['count'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    return ReportSnapshot(
      id: doc.id,
      period: period,
      periodStart: (data['periodStart'] as Timestamp).toDate(),
      periodEnd: (data['periodEnd'] as Timestamp).toDate(),
      report: DashboardReport(
        monthLabel: data['periodLabel'] as String? ?? '',
        totalSessions: (data['totalSessions'] as num?)?.toInt() ?? 0,
        completedSessions: (data['completedSessions'] as num?)?.toInt() ?? 0,
        cancelledSessions: (data['cancelledSessions'] as num?)?.toInt() ?? 0,
        trainerPerformance: trainerPerformance,
        estimatedRevenueTl: (data['estimatedRevenueTl'] as num?)?.toInt() ?? 0,
        totalExpensesTl: (data['totalExpensesTl'] as num?)?.toInt() ?? 0,
      ),
      packages: packages,
      groupSessions: _occupancyFrom(data['groupSessions']),
      events: _occupancyFrom(data['events']),
    );
  }

  ReportOccupancy _occupancyFrom(Object? raw) {
    final map = raw as Map<String, dynamic>?;
    if (map == null) return ReportOccupancy.empty;
    return ReportOccupancy(
      count: (map['count'] as num?)?.toInt() ?? 0,
      capacity: (map['capacity'] as num?)?.toInt() ?? 0,
      attendance: (map['attendance'] as num?)?.toInt() ?? 0,
    );
  }
}

@riverpod
ReportSnapshotService reportSnapshotService(ReportSnapshotServiceRef ref) =>
    const ReportSnapshotService();
