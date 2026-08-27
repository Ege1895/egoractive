import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/report_snapshot.dart';
import '../repository/report_snapshot_repository.dart';

part 'report_snapshot_controller.g.dart';

/// F5-20 fix — BİLEREK public (alt çizgisiz): `_PastReportsSection`
/// widget'ının BUNU doğrudan `ref.watch` etmesi lazım. Önceki sürümde bu
/// provider sadece `ReportSnapshotController`'ın getter'ları içinden
/// izleniyordu — controller'ın kendi `build()`'ı bunu HİÇ izlemediğinden
/// (sadece `ReportPeriod`'u tutuyor), veri yüklenip bittiğinde
/// `ReportSnapshotController`'ın çıktısı DEĞİŞMİYOR (aynı `ReportPeriod`
/// değeri), Riverpod da eşit çıktıda dinleyicileri (bu widget'ı) HİÇ
/// tetiklemiyordu — ekran sonsuza kadar ilk (loading) durumda donuk
/// kalıyordu.
@riverpod
Future<List<ReportSnapshot>> reportSnapshotsForGym(
  ReportSnapshotsForGymRef ref,
  String gymId,
  ReportPeriod period,
) {
  return ref
      .watch(reportSnapshotRepositoryProvider)
      .loadSnapshots(gymId, period);
}

/// F5-9 — Raporlar ekranındaki "Geçmiş Raporlar" bölümünün seçili
/// haftalık/aylık filtresi. Asıl veri [reportSnapshotsForGymProvider]'dan
/// gelir — UI bunu DOĞRUDAN izlemeli (bkz. yukarıdaki not), bu controller
/// sadece filtre state'ini ve `retry()`'ı sağlar.
@riverpod
class ReportSnapshotController extends _$ReportSnapshotController {
  @override
  ReportPeriod build() => ReportPeriod.weekly;

  void selectPeriod(ReportPeriod period) => state = period;

  void retry() {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    ref.invalidate(reportSnapshotsForGymProvider(gymId, state));
  }
}
