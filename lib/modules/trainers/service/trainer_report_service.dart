import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_report_state.dart';

part 'trainer_report_service.g.dart';

/// Mock servis — F3'te gerçek `sessions`/`payroll` verisine bağlanacak.
class TrainerReportService {
  const TrainerReportService();

  TrainerReportState loadInitial() {
    return TrainerReportState(
      startDate: '1 Tem 2026',
      endDate: '31 Tem 2026',
      period: TrainerReportPeriod.monthly,
      periodStart: DateTime(2026, 7, 1),
      periodEnd: DateTime(2026, 7, 31),
      gymJoinedAt: DateTime(2026, 1, 1),
      breakdown: const [
        TrainerReportBreakdown(
          title: 'Toplam seanslar',
          total: 66,
          solo: 44,
          group: 17,
          duet: 5,
        ),
        TrainerReportBreakdown(
          title: 'Tamamlanan seanslar',
          total: 58,
          solo: 39,
          group: 15,
          duet: 4,
        ),
        TrainerReportBreakdown(
          title: 'İptal edilen seanslar',
          total: 8,
          solo: 5,
          group: 2,
          duet: 1,
        ),
      ],
    );
  }
}

@riverpod
TrainerReportService trainerReportService(TrainerReportServiceRef ref) =>
    const TrainerReportService();
