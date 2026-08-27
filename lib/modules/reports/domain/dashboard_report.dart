import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_report.freezed.dart';

@freezed
class TrainerPerformance with _$TrainerPerformance {
  const factory TrainerPerformance({
    required String trainerId,
    required String name,
    required int completedSessions,
    required int totalSessions,
    // F5-11 rapor snapshot'larında var; canlı dashboard özetinde henüz
    // hesaplanmıyor (bkz. DashboardReportService.loadTrainerPerformance),
    // o yüzden varsayılan 0.
    @Default(0) int cancelledSessions,
  }) = _TrainerPerformance;

  const TrainerPerformance._();

  double get completionRatio =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;
}

/// F7-2 — antrenör performans dökümü (`trainerPerformance`) ayrı, daha
/// yavaş bir sorgu grubuna (antrenör başına 2 `count()`) ayrıldığı için
/// [DashboardSummary] artık sadece hızlı temel metrikleri taşır. Bu sayede
/// dashboard ilk render'ı antrenör dökümünü beklemeden yapılabiliyor —
/// bkz. `DashboardReportController`.
@freezed
class DashboardSummary with _$DashboardSummary {
  const factory DashboardSummary({
    required String monthLabel,
    required int totalSessions,
    required int completedSessions,
    required int cancelledSessions,
    required int estimatedRevenueTl,
    required int totalExpensesTl,
  }) = _DashboardSummary;

  const DashboardSummary._();

  static const empty = DashboardSummary(
    monthLabel: '',
    totalSessions: 0,
    completedSessions: 0,
    cancelledSessions: 0,
    estimatedRevenueTl: 0,
    totalExpensesTl: 0,
  );

  double get completionRatio =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;
  double get cancellationRatio =>
      totalSessions == 0 ? 0 : cancelledSessions / totalSessions;
  int get netTl => estimatedRevenueTl - totalExpensesTl;
}

@freezed
class DashboardReport with _$DashboardReport {
  const factory DashboardReport({
    required String monthLabel,
    required int totalSessions,
    required int completedSessions,
    required int cancelledSessions,
    required List<TrainerPerformance> trainerPerformance,
    required int estimatedRevenueTl,
    required int totalExpensesTl,
  }) = _DashboardReport;

  const DashboardReport._();

  static const empty = DashboardReport(
    monthLabel: '',
    totalSessions: 0,
    completedSessions: 0,
    cancelledSessions: 0,
    trainerPerformance: [],
    estimatedRevenueTl: 0,
    totalExpensesTl: 0,
  );

  factory DashboardReport.from(
    DashboardSummary summary,
    List<TrainerPerformance> trainerPerformance,
  ) {
    return DashboardReport(
      monthLabel: summary.monthLabel,
      totalSessions: summary.totalSessions,
      completedSessions: summary.completedSessions,
      cancelledSessions: summary.cancelledSessions,
      trainerPerformance: trainerPerformance,
      estimatedRevenueTl: summary.estimatedRevenueTl,
      totalExpensesTl: summary.totalExpensesTl,
    );
  }

  double get completionRatio =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;
  double get cancellationRatio =>
      totalSessions == 0 ? 0 : cancelledSessions / totalSessions;
  int get netTl => estimatedRevenueTl - totalExpensesTl;
}
