import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/mock/trainer_mock_data.dart';
import '../domain/trainer_member_detail.dart';
import '../domain/trainer_metric.dart';

part 'trainer_member_detail_service.g.dart';

const _months = ['Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu'];

/// Mock servis — F3'te üyenin gerçek ders geçmişi/ölçüm verisine bağlanacak.
class TrainerMemberDetailService {
  const TrainerMemberDetailService();

  TrainerMemberDetail loadDetail(String memberId) {
    final member = TrainerMockData.memberById(memberId);
    return TrainerMemberDetail(
      id: member.id,
      initials: member.initials,
      name: member.name,
      phone: member.phone,
      memberSince: member.memberSince,
      remainingSessions: member.remainingSessions,
      packageEndDate: member.packageEndDate,
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
TrainerMemberDetailService trainerMemberDetailService(TrainerMemberDetailServiceRef ref) {
  return const TrainerMemberDetailService();
}
