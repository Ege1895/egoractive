import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/dashboard_report.dart';
import '../repository/dashboard_report_repository.dart';

part 'dashboard_report_controller.g.dart';

@riverpod
Future<DashboardSummary> _summaryForGym(_SummaryForGymRef ref, String gymId) {
  return ref.watch(dashboardReportRepositoryProvider).loadSummary(gymId);
}

@riverpod
Future<List<TrainerPerformance>> _trainerPerformanceForGym(
  _TrainerPerformanceForGymRef ref,
  String gymId,
) {
  return ref
      .watch(dashboardReportRepositoryProvider)
      .loadTrainerPerformance(gymId);
}

/// F5-1 — Admin dashboard: aylık seans/ciro/gider özeti + antrenör
/// performansı. Aktif salon bilinmiyorsa (test ortamı vb.) boş rapor
/// gösterilir.
///
/// F7-2 — özet ve antrenör dökümü BİLEREK ayrı iki provider'dan geliyor:
/// antrenör dökümü (antrenör başına 2 `count()` sorgusu) büyük salonlarda
/// asıl maliyeti taşıyor (bkz. `DashboardReportService` dokümantasyonu).
/// Ayrı tutulunca özet metrikler antrenör dökümünü beklemeden render
/// edilebiliyor — `isSummaryLoading`/`isTrainerPerformanceLoading` panel'in
/// bu ikisini ayrı ayrı göstermesini sağlıyor.
@riverpod
class DashboardReportController extends _$DashboardReportController {
  @override
  DashboardReport build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return DashboardReport.empty;

    final summary =
        ref.watch(_summaryForGymProvider(gymId)).valueOrNull ??
        DashboardSummary.empty;
    final trainerPerformance =
        ref.watch(_trainerPerformanceForGymProvider(gymId)).valueOrNull ??
        const [];
    return DashboardReport.from(summary, trainerPerformance);
  }

  bool get isSummaryLoading {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_summaryForGymProvider(gymId)).isLoading;
  }

  bool get isTrainerPerformanceLoading {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_trainerPerformanceForGymProvider(gymId)).isLoading;
  }

  /// Sorgu hatası (index eksikliği, izin, network) `valueOrNull` ile
  /// sessizce boş/sıfır veriye düşüyordu — admin gerçekten "bu ay veri yok"
  /// ile "rapor yüklenemedi" arasındaki farkı göremiyordu. Panel bu iki
  /// getter ile ayırt edip bir hata mesajı gösterebiliyor.
  bool get hasSummaryError {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_summaryForGymProvider(gymId)).hasError;
  }

  bool get hasTrainerPerformanceError {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_trainerPerformanceForGymProvider(gymId)).hasError;
  }

  void retry() {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    ref.invalidate(_summaryForGymProvider(gymId));
    ref.invalidate(_trainerPerformanceForGymProvider(gymId));
  }
}
