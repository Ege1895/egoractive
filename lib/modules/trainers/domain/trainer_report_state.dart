import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_report_state.freezed.dart';

@freezed
class TrainerReportBreakdown with _$TrainerReportBreakdown {
  const factory TrainerReportBreakdown({
    required String title,
    required int total,
    required int solo,
    required int group,
  }) = _TrainerReportBreakdown;
}

@freezed
class TrainerReportState with _$TrainerReportState {
  const factory TrainerReportState({
    required String startDate,
    required String endDate,
    required List<TrainerReportBreakdown> breakdown,
  }) = _TrainerReportState;
}
