import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_report.freezed.dart';

@freezed
class TrainerPerformance with _$TrainerPerformance {
  const factory TrainerPerformance({
    required String trainerId,
    required String name,
    required int completedSessions,
    required int totalSessions,
  }) = _TrainerPerformance;

  const TrainerPerformance._();

  double get completionRatio => totalSessions == 0 ? 0 : completedSessions / totalSessions;
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

  double get completionRatio => totalSessions == 0 ? 0 : completedSessions / totalSessions;
  double get cancellationRatio => totalSessions == 0 ? 0 : cancelledSessions / totalSessions;
  int get netTl => estimatedRevenueTl - totalExpensesTl;
}
