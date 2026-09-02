import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/trainer_member_detail.dart';
import '../domain/trainer_member_detail_mapper.dart';
import '../domain/trainer_metric.dart';
import '../domain/trainer_metric_measurement_source.dart';
import '../repository/trainer_member_detail_repository.dart';
import '../../../shared/utils/date_labels.dart';
import '../../../core/remote_config/remote_config_service.dart';

part 'trainer_member_detail_controller.g.dart';

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
  final labels = ref.watch(dateLabelsProvider);
  final texts = _HistoryLabels(
    soloWithTimeTemplate: ref.watch(
      rcTextProvider(RemoteConfigKeys.commonSoloSessionWithTimeTemplate),
    ),
    completed: ref.watch(rcTextProvider(RemoteConfigKeys.commonTamamlandi)),
    cancelled: ref.watch(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
  );
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
            .map((doc) => _toHistoryEntry(doc, labels, texts))
            .toList();
      });
}

SessionHistoryEntry _toHistoryEntry(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
  DateLabels labels,
  _HistoryLabels texts,
) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  final isCompleted = data['status'] == 'completed';
  return SessionHistoryEntry(
    date: labels.dayMonthShort(startTime),
    type: texts.soloWithTimeTemplate.replaceAll('{time}', time),
    stateLabel: isCompleted ? texts.completed : texts.cancelled,
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
  return watchTrainerMetricSeries(memberId, ref.watch(dateLabelsProvider));
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

/// Seans geçmişi satırındaki sabit metinler — RC'den okunup buraya
/// taşınıyor (servis/mapper katmanı RC'ye erişmiyor).
class _HistoryLabels {
  const _HistoryLabels({
    required this.soloWithTimeTemplate,
    required this.completed,
    required this.cancelled,
  });

  final String soloWithTimeTemplate;
  final String completed;
  final String cancelled;
}
