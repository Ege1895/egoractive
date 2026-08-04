import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_report_state.dart';

part 'trainer_report_service.g.dart';

/// Mock servis — F3'te gerçek `sessions`/`payroll` verisine bağlanacak.
class TrainerReportService {
  const TrainerReportService();

  TrainerReportState loadInitial() {
    return const TrainerReportState(
      startDate: '1 Tem 2026',
      endDate: '31 Tem 2026',
      bonusAmount: '₺18.900',
      completedSessionCount: 54,
      perSessionRate: '₺350',
      breakdown: [
        TrainerReportBreakdown(title: 'Toplam seanslar', total: 61, solo: 44, group: 17),
        TrainerReportBreakdown(title: 'Tamamlanan seanslar', total: 54, solo: 39, group: 15),
        TrainerReportBreakdown(title: 'İptal edilen seanslar', total: 7, solo: 5, group: 2),
      ],
    );
  }
}

@riverpod
TrainerReportService trainerReportService(TrainerReportServiceRef ref) => const TrainerReportService();
