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
class DuePayment with _$DuePayment {
  const factory DuePayment({
    required String memberName,
    required String dueDate,
    required String amount,
  }) = _DuePayment;
}

@freezed
class AdminHomeState with _$AdminHomeState {
  const factory AdminHomeState({
    required String monthLabel,
    required int totalSessions,
    required int completedSessions,
    required int cancelledSessions,
    required String estimatedRevenue,
    required String revenueChangeLabel,
    required String expenses,
    required List<TrainerPerformance> trainerPerformance,
    required List<DuePayment> duePayments,
    required int pendingFeedbackCount,
    required int recentFeedbackDays,
  }) = _AdminHomeState;

  const AdminHomeState._();

  double get completionRatio => totalSessions == 0 ? 0 : completedSessions / totalSessions;
}
