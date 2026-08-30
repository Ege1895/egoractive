import 'package:freezed_annotation/freezed_annotation.dart';

part 'trainer_report_state.freezed.dart';

enum TrainerReportPeriod { weekly, monthly, allTime, custom }

@freezed
class TrainerReportBreakdown with _$TrainerReportBreakdown {
  const factory TrainerReportBreakdown({
    required String title,
    required int total,
    required int solo,
    required int group,
    required int duet,
  }) = _TrainerReportBreakdown;
}

@freezed
class TrainerReportState with _$TrainerReportState {
  const factory TrainerReportState({
    required String startDate,
    required String endDate,
    required TrainerReportPeriod period,
    required DateTime periodStart,
    required DateTime periodEnd,

    /// Antrenörün salona katıldığı tarih ("Tüm zamanlar" alt sınırı ve
    /// "Özel" tarih seçicisinin firstDate'i) — `users/{uid}.createdAt`.
    required DateTime gymJoinedAt,
    required List<TrainerReportBreakdown> breakdown,
  }) = _TrainerReportState;
}
