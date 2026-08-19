import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/utils/tr_date_formatter.dart';
import '../domain/trainer_report_state.dart';
import '../repository/trainer_report_repository.dart';

part 'trainer_report_controller.g.dart';

@riverpod
Future<TrainerReportState> reportForTrainer(
  ReportForTrainerRef ref,
  String trainerId,
) async {
  final now = DateTime.now();
  final monthStart = Timestamp.fromDate(DateTime(now.year, now.month, 1));
  // `count()`/`status` bazlı ayrı aggregate sorguları trainerId+status+
  // startTime için yeni bir composite index gerektirirdi — tek bir
  // trainerId+startTime sorgusuyla (mevcut index) dokümanlar çekilip
  // durum sayımı client tarafında yapılıyor; tek bir antrenörün aylık
  // seans sayısı küçük olduğu için bu maliyetli değil.
  final snapshot = await FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('startTime', isGreaterThanOrEqualTo: monthStart)
      .get();
  final total = snapshot.docs.length;
  final completed = snapshot.docs
      .where((doc) => doc.data()['status'] == 'completed')
      .length;
  final cancelled = snapshot.docs
      .where((doc) => doc.data()['status'] == 'cancelled')
      .length;

  // `sessions` koleksiyonu hâlâ sadece birebir dersleri tutuyor (grup
  // dersleri ayrı bir `groupSessions` koleksiyonunda) — bu yüzden birebir/
  // grup kırılımı yerine tüm sayı `solo`'ya yazılıyor. Antrenör başına bir
  // prim/komisyon oranı hiçbir yerde tanımlı değil (henüz bir "prim
  // sistemi" yok, bkz. panelin "Prim sistemine git" pasif butonu) — bu
  // yüzden bonusAmount/perSessionRate uydurulmuyor, "—" olarak kalıyor.
  return TrainerReportState(
    startDate: formatTrDate(DateTime(now.year, now.month, 1)),
    endDate: formatTrDate(now),
    bonusAmount: '—',
    completedSessionCount: completed,
    perSessionRate: '—',
    breakdown: [
      TrainerReportBreakdown(
        title: 'Toplam seanslar',
        total: total,
        solo: total,
        group: 0,
      ),
      TrainerReportBreakdown(
        title: 'Tamamlanan seanslar',
        total: completed,
        solo: completed,
        group: 0,
      ),
      TrainerReportBreakdown(
        title: 'İptal edilen seanslar',
        total: cancelled,
        solo: cancelled,
        group: 0,
      ),
    ],
  );
}

/// Antrenörün kendi (`trainerId == uid`) bu ayki seans özeti gerçek zamanlı
/// hesaplanır. Oturum yoksa (test ortamı vb.) mock repository'e düşer.
@riverpod
class TrainerReportController extends _$TrainerReportController {
  @override
  TrainerReportState build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      return ref.watch(trainerReportRepositoryProvider).loadInitial();
    }
    return ref.watch(reportForTrainerProvider(uid)).valueOrNull ??
        _loadingState();
  }

  TrainerReportState _loadingState() {
    final now = DateTime.now();
    return TrainerReportState(
      startDate: formatTrDate(DateTime(now.year, now.month, 1)),
      endDate: formatTrDate(now),
      bonusAmount: '—',
      completedSessionCount: 0,
      perSessionRate: '—',
      breakdown: const [
        TrainerReportBreakdown(
          title: 'Toplam seanslar',
          total: 0,
          solo: 0,
          group: 0,
        ),
        TrainerReportBreakdown(
          title: 'Tamamlanan seanslar',
          total: 0,
          solo: 0,
          group: 0,
        ),
        TrainerReportBreakdown(
          title: 'İptal edilen seanslar',
          total: 0,
          solo: 0,
          group: 0,
        ),
      ],
    );
  }
}
