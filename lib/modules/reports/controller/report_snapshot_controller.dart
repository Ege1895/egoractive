import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/report_snapshot.dart';
import '../repository/report_snapshot_repository.dart';

part 'report_snapshot_controller.g.dart';

@riverpod
Future<List<ReportSnapshot>> _snapshotsForGym(
  _SnapshotsForGymRef ref,
  String gymId,
  ReportPeriod period,
) {
  return ref
      .watch(reportSnapshotRepositoryProvider)
      .loadSnapshots(gymId, period);
}

/// F5-9 — Raporlar ekranındaki "Geçmiş Raporlar" bölümü: state, o an seçili
/// haftalık/aylık filtredir; [snapshots]/[isLoading]/[hasError] getter'ları
/// bu filtreye göre `gyms/{gymId}/reportSnapshots`'tan (F5-7/F5-8) okunan
/// listeyi sunar. `DashboardReportController`'daki aynı desen (getter'larda
/// `ref.watch`, ayrı bir `_snapshotsForGym` family provider) izlenir.
@riverpod
class ReportSnapshotController extends _$ReportSnapshotController {
  @override
  ReportPeriod build() => ReportPeriod.weekly;

  void selectPeriod(ReportPeriod period) => state = period;

  List<ReportSnapshot> get snapshots {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return const [];
    return ref.watch(_snapshotsForGymProvider(gymId, state)).valueOrNull ??
        const [];
  }

  bool get isLoading {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_snapshotsForGymProvider(gymId, state)).isLoading;
  }

  bool get hasError {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return false;
    return ref.watch(_snapshotsForGymProvider(gymId, state)).hasError;
  }

  void retry() {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    ref.invalidate(_snapshotsForGymProvider(gymId, state));
  }
}
