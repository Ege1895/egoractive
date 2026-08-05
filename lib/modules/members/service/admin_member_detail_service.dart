import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../trainers/domain/trainer_member_detail.dart';
import '../../trainers/domain/trainer_metric.dart';
import '../domain/admin_member_detail.dart';
import 'admin_members_service.dart';

part 'admin_member_detail_service.g.dart';

const _months = ['Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu'];

/// Mock servis — F2'de gerçek üye/ödeme/ölçüm verisine bağlanacak.
class AdminMemberDetailService {
  const AdminMemberDetailService();

  AdminMemberDetail loadDetail(String memberId) {
    final member = const AdminMembersService().loadMembers().firstWhere((m) => m.id == memberId);
    return AdminMemberDetail(
      id: member.id,
      initials: member.initials,
      name: member.name,
      phone: member.phone,
      trainerName: member.trainerName,
      remainingSessions: member.remainingSessions,
      makeupSessions: 2,
      packageEndDate: member.packageEndDate,
      paymentTotalTl: 14400,
      paymentPaidTl: 9600,
      lastPaymentDate: '8 Ağustos',
      history: const [
        SessionHistoryEntry(date: '30 Tem', type: 'Birebir · 18:30', stateLabel: 'Tamamlandı', isPositive: true),
        SessionHistoryEntry(date: '27 Tem', type: 'Birebir · 18:30', stateLabel: 'Tamamlandı', isPositive: true),
        SessionHistoryEntry(date: '23 Tem', type: 'Birebir · 18:30', stateLabel: 'İptal', isPositive: false),
        SessionHistoryEntry(date: '20 Tem', type: 'Birebir · 18:30', stateLabel: 'Tamamlandı', isPositive: true),
      ],
      seriesByMetric: const {
        TrainerMetric.kilo: TrainerMetricSeries(metric: TrainerMetric.kilo, values: [68.4, 67.8, 67.1, 66.5, 65.9, 65.2], months: _months),
        TrainerMetric.belCevresi: TrainerMetricSeries(metric: TrainerMetric.belCevresi, values: [82, 81, 80, 79.2, 78.5, 77.6], months: _months),
        TrainerMetric.yagOrani: TrainerMetricSeries(metric: TrainerMetric.yagOrani, values: [27.5, 26.8, 26.1, 25.4, 24.9, 24.1], months: _months),
      },
    );
  }
}

@riverpod
AdminMemberDetailService adminMemberDetailService(AdminMemberDetailServiceRef ref) => const AdminMemberDetailService();
