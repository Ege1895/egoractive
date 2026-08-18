import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../../feedback/controller/admin_feedback_controller.dart';
import '../../reports/controller/dashboard_report_controller.dart';
import '../domain/admin_home_state.dart';
import '../repository/admin_home_repository.dart';
import '../service/admin_home_service.dart';

part 'admin_home_controller.g.dart';

@riverpod
Future<DuePaymentsSummary> _duePaymentsForGym(
  _DuePaymentsForGymRef ref,
  String gymId,
) {
  return ref.watch(adminHomeRepositoryProvider).loadDuePaymentsSummary(gymId);
}

/// Admin 1 · Ana Sayfa — aylık seans/ciro/antrenör performansı zaten
/// `DashboardReportController` (reports modülü) tarafından gerçek zamanlı
/// hesaplanıyor, burada tekrar sorgulanmıyor. Sadece bu panele özel
/// "ödemesi bekleyen üye" özeti (`memberPackages.dueAmount`) ve toplam geri
/// bildirim sayısı (`AdminFeedbackController`) ek olarak izleniyor.
@riverpod
class AdminHomeController extends _$AdminHomeController {
  @override
  AdminHomeState build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    final report = ref.watch(dashboardReportControllerProvider);
    final feedbackCount = ref.watch(adminFeedbackControllerProvider).totalCount;
    final duePayments = gymId == null
        ? DuePaymentsSummary.empty
        : ref.watch(_duePaymentsForGymProvider(gymId)).valueOrNull ??
              DuePaymentsSummary.empty;

    return AdminHomeState(
      monthLabel: report.monthLabel,
      totalSessions: report.totalSessions,
      completedSessions: report.completedSessions,
      cancelledSessions: report.cancelledSessions,
      estimatedRevenueTl: report.estimatedRevenueTl,
      expensesTl: report.totalExpensesTl,
      trainerPerformance: report.trainerPerformance
          .map(
            (t) => TrainerPerformance(
              name: t.name,
              sessionCount: t.completedSessions,
              ratio: t.completionRatio,
            ),
          )
          .toList(),
      duePaymentMemberCount: duePayments.memberCount,
      duePaymentTotalTl: duePayments.totalTl,
      feedbackCount: feedbackCount,
    );
  }
}
