import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/domain/membership_installment.dart';
import '../../trainers/domain/trainer_member_detail.dart';
import '../../trainers/domain/trainer_metric.dart';

part 'admin_member_detail.freezed.dart';

@freezed
class AdminMemberDetail with _$AdminMemberDetail {
  const factory AdminMemberDetail({
    required String id,
    required String initials,
    required String name,
    required String phone,
    required String trainerName,
    required int remainingSessions,
    required int makeupSessions,
    required String packageEndDate,
    required int paymentTotalTl,
    required int paymentPaidTl,
    required String lastPaymentDate,
    required List<SessionHistoryEntry> history,
    required Map<TrainerMetric, TrainerMetricSeries> seriesByMetric,
    @Default(TrainerMetric.kilo) TrainerMetric selectedMetric,
    @Default(false) bool isLoading,
    @Default(false) bool notFound,

    /// Aktif `memberPackages` dokümanının id'si — taksit güncellemesi
    /// yazılırken hangi dokümanın patch'leneceğini bilmek için gerekli.
    String? packageDocId,
    @Default(<MembershipInstallment>[])
    List<MembershipInstallment> installments,
  }) = _AdminMemberDetail;

  const AdminMemberDetail._();

  int get paymentDueTl =>
      (paymentTotalTl - paymentPaidTl).clamp(0, paymentTotalTl);
}
