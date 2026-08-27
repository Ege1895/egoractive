import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/report_snapshot.dart';
import '../service/report_snapshot_service.dart';

part 'report_snapshot_repository.g.dart';

abstract interface class ReportSnapshotRepository {
  Future<List<ReportSnapshot>> loadSnapshots(String gymId, ReportPeriod period);
}

class ReportSnapshotRepositoryImpl implements ReportSnapshotRepository {
  const ReportSnapshotRepositoryImpl(this._service);

  final ReportSnapshotService _service;

  @override
  Future<List<ReportSnapshot>> loadSnapshots(
    String gymId,
    ReportPeriod period,
  ) => _service.loadSnapshots(gymId, period);
}

@riverpod
ReportSnapshotRepository reportSnapshotRepository(
  ReportSnapshotRepositoryRef ref,
) {
  return ReportSnapshotRepositoryImpl(ref.watch(reportSnapshotServiceProvider));
}
