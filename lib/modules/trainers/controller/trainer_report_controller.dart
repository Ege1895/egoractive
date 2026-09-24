import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/trainer_report_state.dart';
import '../repository/trainer_report_repository.dart';
import '../../../shared/utils/date_labels.dart';
import '../../../core/remote_config/remote_config_service.dart';

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
  final labels = ref.watch(dateLabelsProvider);
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
  final gymId = trainerDoc.data()?['gymId'] as String?;

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
  // `gymId` filtresi olmadan bu sorgu, admin (kendi seansı olmayan, sadece
  // `resource.data.gymId == myGymId()` şartını sağlayan) bir antrenörün
  // detayına girdiğinde `firestore.rules`'taki `sessions` okuma kuralı
  // yüzünden her zaman permission-denied ile reddediliyordu (aynı kalıp
  // daha önce `_trainerHasConflict`'te de yaşanmıştı) — "Bu ayın verileri
  // yüklenemedi." hatasının kaynağı buydu.
  var query = FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
      .where('startTime', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
  if (gymId != null) {
    query = query.where('gymId', isEqualTo: gymId);
  }
  final snapshot = await query.get();

  // `sessions` koleksiyonu birebir VE düet dersleri birlikte tutuyor
  // (`sessionType`); grup dersleri hâlâ ayrı `groupSessions`
  // koleksiyonunda ve şu an hiçbir antrenöre atanmadığından (sadece admin
  // oluşturabiliyor, `trainerName` her zaman oluşturan admin'in adı) grup
  // kırılımı hesaplanamıyor, `group` her zaman 0. Bir düet dersin her
  // üyesi kendi dokümanına sahip (aynı `duetGroupId`'yi paylaşıyor) — çift
  // saymamak için grup id'ye göre tekilleştiriliyor.
  var soloTotal = 0;
  var soloCompleted = 0;
  var soloCancelled = 0;
  final duetTotalGroups = <String>{};
  final duetCompletedGroups = <String>{};
  final duetCancelledGroups = <String>{};

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final status = data['status'] as String?;
    if (data['sessionType'] == 'duet') {
      final groupId = data['duetGroupId'] as String?;
      if (groupId == null) continue;
      duetTotalGroups.add(groupId);
      if (status == 'completed') duetCompletedGroups.add(groupId);
      if (status == 'cancelled') duetCancelledGroups.add(groupId);
    } else {
      soloTotal++;
      if (status == 'completed') soloCompleted++;
      if (status == 'cancelled') soloCancelled++;
    }
  }

  return TrainerReportState(
    startDate: labels.dayMonthYear(start),
    endDate: labels.dayMonthYear(end),
    period: period,
    periodStart: start,
    periodEnd: end,
    gymJoinedAt: gymJoinedAt,
    breakdown: [
      TrainerReportBreakdown(
        title: ref.read(
          rcTextProvider(RemoteConfigKeys.trainersReportBreakdownTotal),
        ),
        total: soloTotal + duetTotalGroups.length,
        solo: soloTotal,
        group: 0,
        duet: duetTotalGroups.length,
      ),
      TrainerReportBreakdown(
        title: ref.read(
          rcTextProvider(RemoteConfigKeys.trainersReportBreakdownCompleted),
        ),
        total: soloCompleted + duetCompletedGroups.length,
        solo: soloCompleted,
        group: 0,
        duet: duetCompletedGroups.length,
      ),
      TrainerReportBreakdown(
        title: ref.read(
          rcTextProvider(RemoteConfigKeys.trainersReportBreakdownCancelled),
        ),
        total: soloCancelled + duetCancelledGroups.length,
        solo: soloCancelled,
        group: 0,
        duet: duetCancelledGroups.length,
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
    final authAsync = ref.watch(authStateProvider);
    // F13-6 — provider ilk izlendiğinde henüz sonuçlanmamış olabilir; bu
    // durum "gerçekten oturum yok" ile AYNI DEĞİL. O ana kadar mock'a
    // düşülürse kullanıcı bir an sahte veriyi gerçekmiş gibi görür ve
    // dokunduğunda var olmayan bir ID ile Firestore'a yazma denenir (bkz.
    // `discover_controller.dart`/`trainer_home_controller.dart` — aynı hata
    // orada yaşandı ve düzeltildi).
    if (authAsync.isLoading) return _loadingState();
    final uid = authAsync.valueOrNull?.uid;
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
    final labels = ref.read(dateLabelsProvider);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, now.day);
    return TrainerReportState(
      startDate: labels.dayMonthYear(start),
      endDate: labels.dayMonthYear(now),
      period: TrainerReportPeriod.monthly,
      periodStart: start,
      periodEnd: now,
      gymJoinedAt: _defaultGymJoinedAt,
      breakdown: [
        TrainerReportBreakdown(
          title: ref.read(
            rcTextProvider(RemoteConfigKeys.trainersReportBreakdownTotal),
          ),
          total: 0,
          solo: 0,
          group: 0,
          duet: 0,
        ),
        TrainerReportBreakdown(
          title: ref.read(
            rcTextProvider(RemoteConfigKeys.trainersReportBreakdownCompleted),
          ),
          total: 0,
          solo: 0,
          group: 0,
          duet: 0,
        ),
        TrainerReportBreakdown(
          title: ref.read(
            rcTextProvider(RemoteConfigKeys.trainersReportBreakdownCancelled),
          ),
          total: 0,
          solo: 0,
          group: 0,
          duet: 0,
        ),
      ],
    );
  }
}
