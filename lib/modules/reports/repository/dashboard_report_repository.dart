import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';
import '../service/dashboard_report_service.dart';

part 'dashboard_report_repository.g.dart';

abstract interface class DashboardReportRepository {
  Future<DashboardSummary> loadSummary(String gymId);
  Future<List<TrainerPerformance>> loadTrainerPerformance(String gymId);
}

class DashboardReportRepositoryImpl implements DashboardReportRepository {
  const DashboardReportRepositoryImpl(this._service);

  final DashboardReportService _service;

  @override
  Future<DashboardSummary> loadSummary(String gymId) => _service.loadSummary(gymId);

  @override
  Future<List<TrainerPerformance>> loadTrainerPerformance(String gymId) => _service.loadTrainerPerformance(gymId);
}

@riverpod
DashboardReportRepository dashboardReportRepository(DashboardReportRepositoryRef ref) {
  return DashboardReportRepositoryImpl(ref.watch(dashboardReportServiceProvider));
}
