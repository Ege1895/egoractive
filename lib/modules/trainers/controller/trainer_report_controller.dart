import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_report_state.dart';
import '../repository/trainer_report_repository.dart';

part 'trainer_report_controller.g.dart';

@riverpod
class TrainerReportController extends _$TrainerReportController {
  @override
  TrainerReportState build() => ref.watch(trainerReportRepositoryProvider).loadInitial();
}
