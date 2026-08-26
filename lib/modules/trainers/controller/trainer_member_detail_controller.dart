import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/trainer_member_detail.dart';
import '../domain/trainer_member_detail_mapper.dart';
import '../domain/trainer_metric.dart';
import '../domain/trainer_metric_measurement_source.dart';
import '../repository/trainer_member_detail_repository.dart';

part 'trainer_member_detail_controller.g.dart';

const _monthAbbrev = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

@riverpod
Stream<TrainerMemberDetail> _trainerDetailStreamForId(
  _TrainerDetailStreamForIdRef ref,
  String memberId,
) {
  return ref.watch(trainerMemberDetailRepositoryProvider).watchDetail(memberId);
}

/// Bir index gerektirmemek için sadece `trainerId` eşitliğiyle sorgulanır
/// (bkz. trainer_home_controller/trainer_calendar_controller'daki aynı
/// desen), `memberId`/durum filtresi client-side yapılır.
@riverpod
Stream<List<SessionHistoryEntry>> _sessionHistoryForMember(
  _SessionHistoryForMemberRef ref,
  String trainerId,
  String memberId,
) {
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('trainerId', isEqualTo: trainerId)
      .orderBy('startTime', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .where((doc) => doc.data()['memberId'] == memberId)
            .where((doc) {
              final status = doc.data()['status'] as String?;
              return status == 'completed' || status == 'cancelled';
            })
            .take(10)
            .map(_toHistoryEntry)
            .toList();
      });
}

SessionHistoryEntry _toHistoryEntry(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  final isCompleted = data['status'] == 'completed';
  return SessionHistoryEntry(
    date: '${startTime.day} ${_monthAbbrev[startTime.month] ?? ''}',
    type: 'Birebir · $time',
    stateLabel: isCompleted ? 'Tamamlandı' : 'İptal',
    isPositive: isCompleted,
  );
}

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
/// antrenörün üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
/// yağ oranı) tamamını tek sorgudan üretir (bkz.
/// `trainer_metric_measurement_source.dart` — admin tarafındaki
/// karşılığıyla aynı kaynak).
@riverpod
Stream<Map<TrainerMetric, TrainerMetricSeries>> _metricSeriesForMember(
  _MetricSeriesForMemberRef ref,
  String memberId,
) {
  return watchTrainerMetricSeries(memberId);
}

@riverpod
class TrainerMemberDetailController extends _$TrainerMemberDetailController {
  @override
  TrainerMemberDetail build(String memberId) {
    final base =
        ref.watch(_trainerDetailStreamForIdProvider(memberId)).valueOrNull ??
        trainerMemberDetailLoadingPlaceholder(memberId);
    final trainerId = ref.watch(authStateProvider).valueOrNull?.uid;
    if (trainerId == null || base.isLoading || base.notFound) return base;

    final history =
        ref
            .watch(_sessionHistoryForMemberProvider(trainerId, memberId))
            .valueOrNull ??
        base.history;
    final metricSeries = ref
        .watch(_metricSeriesForMemberProvider(memberId))
        .valueOrNull;
    return base.copyWith(
      history: history,
      seriesByMetric: metricSeries ?? base.seriesByMetric,
    );
  }

  void selectMetric(TrainerMetric metric) =>
      state = state.copyWith(selectedMetric: metric);
}
