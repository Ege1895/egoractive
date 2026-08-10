import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';
import '../service/dashboard_report_service.dart';

part 'dashboard_report_repository.g.dart';

abstract interface class DashboardReportRepository {
  Future<DashboardReport> loadReport(String gymId);
}

class DashboardReportRepositoryImpl implements DashboardReportRepository {
  const DashboardReportRepositoryImpl(this._service);

  final DashboardReportService _service;

  @override
  Future<DashboardReport> loadReport(String gymId) => _service.loadReport(gymId);
}

@riverpod
DashboardReportRepository dashboardReportRepository(DashboardReportRepositoryRef ref) {
  return DashboardReportRepositoryImpl(ref.watch(dashboardReportServiceProvider));
}
