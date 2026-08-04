import 'package:freezed_annotation/freezed_annotation.dart';

import 'trainer_metric.dart';

part 'trainer_member_detail.freezed.dart';

@freezed
class SessionHistoryEntry with _$SessionHistoryEntry {
  const factory SessionHistoryEntry({
    required String date,
    required String type,
    required String stateLabel,
    required bool isPositive,
  }) = _SessionHistoryEntry;
}

@freezed
class TrainerMetricSeries with _$TrainerMetricSeries {
  const factory TrainerMetricSeries({
    required TrainerMetric metric,
    required List<double> values,
    required List<String> months,
  }) = _TrainerMetricSeries;
}

@freezed
class TrainerMemberDetail with _$TrainerMemberDetail {
  const factory TrainerMemberDetail({
    required String id,
    required String initials,
    required String name,
    required String phone,
    required String memberSince,
    required int remainingSessions,
    required String packageEndDate,
    required List<SessionHistoryEntry> history,
    required Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    @Default(TrainerMetric.kilo) TrainerMetric selectedMetric,
  }) = _TrainerMemberDetail;
}
