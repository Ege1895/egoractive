import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/trainer_member_detail.dart';
import '../domain/trainer_member_detail_mapper.dart';
import '../domain/trainer_metric.dart';
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

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
/// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
/// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
@riverpod
Stream<TrainerMetricSeries> _waistSeriesForMember(
  _WaistSeriesForMemberRef ref,
  String memberId,
) {
  return FirebaseFirestore.instance
      .collection('measurements')
      .doc(memberId)
      .collection('entries')
      .orderBy('date')
      .snapshots()
      .map((snapshot) {
        final months = <String>[];
        final values = <double>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final bel = data['bel'];
          if (bel is num) {
            final date = (data['date'] as Timestamp).toDate();
            months.add(_monthAbbrev[date.month] ?? '');
            values.add(bel.toDouble());
          }
        }
        return TrainerMetricSeries(
          metric: TrainerMetric.belCevresi,
          values: values,
          months: months,
        );
      });
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
    final waistSeries = ref
        .watch(_waistSeriesForMemberProvider(memberId))
        .valueOrNull;
    return base.copyWith(
      history: history,
      seriesByMetric: waistSeries == null
          ? base.seriesByMetric
          : {...base.seriesByMetric, TrainerMetric.belCevresi: waistSeries},
    );
  }

  void selectMetric(TrainerMetric metric) =>
      state = state.copyWith(selectedMetric: metric);
}
