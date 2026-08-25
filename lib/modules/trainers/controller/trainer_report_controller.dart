import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/utils/tr_date_formatter.dart';
import '../domain/trainer_report_state.dart';
import '../repository/trainer_report_repository.dart';

part 'trainer_report_controller.g.dart';

final _defaultGymJoinedAt = DateTime.utc(2020);

@riverpod
class _TrainerReportPeriod extends _$TrainerReportPeriod {
  @override
  TrainerReportPeriod build() => TrainerReportPeriod.monthly;

  void select(TrainerReportPeriod period) => state = period;
}

@riverpod
class _TrainerReportCustomStart extends _$TrainerReportCustomStart {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 1, now.day);
  }

  void select(DateTime date) => state = date;
}

@riverpod
class _TrainerReportCustomEnd extends _$TrainerReportCustomEnd {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

@riverpod
Future<TrainerReportState> reportForTrainer(
  ReportForTrainerRef ref,
  String trainerId,
) async {
  final period = ref.watch(_trainerReportPeriodProvider);
  final customStart = ref.watch(_trainerReportCustomStartProvider);
  final customEnd = ref.watch(_trainerReportCustomEndProvider);

  final trainerDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(trainerId)
      .get();
  final gymJoinedAt =
      (trainerDoc.data()?['createdAt'] as Timestamp?)?.toDate() ??
      _defaultGymJoinedAt;

  final now = DateTime.now();
  final DateTime start;
  final DateTime end;
  switch (period) {
    case TrainerReportPeriod.weekly:
      start = now.subtract(const Duration(days: 7));
      end = now;
    case TrainerReportPeriod.monthly:
      start = DateTime(now.year, now.month - 1, now.day);
      end = now;
    case TrainerReportPeriod.allTime:
      start = gymJoinedAt;
      end = now;
    case TrainerReportPeriod.custom:
      // Başlangıç antrenörün salona katıldığı tarihten, bitiş bugünden
      // ileri gidemez — kullanıcı tarih seçicide bu sınırların dışına
      // hiç çıkamasa da (bkz. panel'deki firstDate/lastDate), state'ten
      // gelen değer eski/farklı bir oturumdan kalmış olabilir diye
      // burada da kenetleniyor.
      start = customStart.isBefore(gymJoinedAt) ? gymJoinedAt : customStart;
      end = customEnd.isAfter(now) ? now : customEnd;
  }
  // `startTime` alanı bir Timestamp (saat içerir) olduğu için bitiş
  // gününün tamamı dahil olsun diye gün sonuna yuvarlanıyor.
  final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

  // `count()`/`status` bazlı ayrı aggregate sorguları trainerId+status+
  // startTime için yeni bir composite index gerektirirdi — tek bir
  // trainerId+startTime sorgusuyla (mevcut index) dokümanlar çekilip
  // durum sayımı client tarafında yapılıyor; tek bir antrenörün seçili
  // aralıktaki seans sayısı küçük olduğu için bu maliyetli değil.
  final snapshot = await FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
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
  // grup kırılımı yerine tüm sayı `solo`'ya yazılıyor.
  return TrainerReportState(
    startDate: formatTrDate(start),
    endDate: formatTrDate(end),
    period: period,
    periodStart: start,
    periodEnd: end,
    gymJoinedAt: gymJoinedAt,
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

/// Antrenörün kendi (`trainerId == uid`) seçili dönem içindeki seans özeti
/// gerçek zamanlı hesaplanır. Oturum yoksa (test ortamı vb.) mock
/// repository'e düşer.
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

  void setPeriod(TrainerReportPeriod period) =>
      ref.read(_trainerReportPeriodProvider.notifier).select(period);

  /// Kullanıcı "Özel" tarih alanlarından birini değiştirdiğinde çağrılır —
  /// dönemi de `custom`a çeker ki seçilen tarihler gerçekten kullanılsın.
  void setCustomRange({DateTime? start, DateTime? end}) {
    if (start != null) {
      ref.read(_trainerReportCustomStartProvider.notifier).select(start);
    }
    if (end != null) {
      ref.read(_trainerReportCustomEndProvider.notifier).select(end);
    }
    ref
        .read(_trainerReportPeriodProvider.notifier)
        .select(TrainerReportPeriod.custom);
  }

  TrainerReportState _loadingState() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, now.day);
    return TrainerReportState(
      startDate: formatTrDate(start),
      endDate: formatTrDate(now),
      period: TrainerReportPeriod.monthly,
      periodStart: start,
      periodEnd: now,
      gymJoinedAt: _defaultGymJoinedAt,
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
