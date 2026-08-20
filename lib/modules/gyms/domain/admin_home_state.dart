import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_home_state.freezed.dart';

@freezed
class TrainerPerformance with _$TrainerPerformance {
  const factory TrainerPerformance({
    required String name,
    required int sessionCount,
    required double ratio,
  }) = _TrainerPerformance;
}

@freezed
class AdminHomeState with _$AdminHomeState {
  const factory AdminHomeState({
    required String monthLabel,
    required int totalSessions,
    required int completedSessions,
    required int cancelledSessions,
    required int estimatedRevenueTl,
    required int expensesTl,
    required List<TrainerPerformance> trainerPerformance,
    required int duePaymentMemberCount,
    required int duePaymentTotalTl,
    required int feedbackCount,
  }) = _AdminHomeState;

  const AdminHomeState._();

  static const empty = AdminHomeState(
    monthLabel: '',
    totalSessions: 0,
    completedSessions: 0,
    cancelledSessions: 0,
    estimatedRevenueTl: 0,
    expensesTl: 0,
    trainerPerformance: [],
    duePaymentMemberCount: 0,
    duePaymentTotalTl: 0,
    feedbackCount: 0,
  );

  double get completionRatio =>
      totalSessions == 0 ? 0 : completedSessions / totalSessions;
}
