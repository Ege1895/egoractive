import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_report_state.dart';
import '../service/trainer_report_service.dart';

part 'trainer_report_repository.g.dart';

abstract interface class TrainerReportRepository {
  TrainerReportState loadInitial();
}

class TrainerReportRepositoryImpl implements TrainerReportRepository {
  const TrainerReportRepositoryImpl(this._service);

  final TrainerReportService _service;

  @override
  TrainerReportState loadInitial() => _service.loadInitial();
}

@riverpod
TrainerReportRepository trainerReportRepository(
  TrainerReportRepositoryRef ref,
) {
  return TrainerReportRepositoryImpl(ref.watch(trainerReportServiceProvider));
}
