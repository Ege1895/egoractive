import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/dashboard_report.dart';
import '../repository/dashboard_report_repository.dart';

part 'dashboard_report_controller.g.dart';

@riverpod
Future<DashboardReport> _reportForGym(_ReportForGymRef ref, String gymId) {
  return ref.watch(dashboardReportRepositoryProvider).loadReport(gymId);
}

/// F5-1 — Admin dashboard: aylık seans/ciro/gider özeti + antrenör
/// performansı. Aktif salon bilinmiyorsa (test ortamı vb.) boş rapor
/// gösterilir.
@riverpod
class DashboardReportController extends _$DashboardReportController {
  @override
  DashboardReport build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return DashboardReport.empty;
    return ref.watch(_reportForGymProvider(gymId)).valueOrNull ?? DashboardReport.empty;
  }

  bool get isLoading {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_reportForGymProvider(gymId)).isLoading;
  }
}
