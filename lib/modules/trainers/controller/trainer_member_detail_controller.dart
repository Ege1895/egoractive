import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_member_detail.dart';
import '../domain/trainer_metric.dart';
import '../repository/trainer_member_detail_repository.dart';

part 'trainer_member_detail_controller.g.dart';

@riverpod
class TrainerMemberDetailController extends _$TrainerMemberDetailController {
  @override
  TrainerMemberDetail build(String memberId) {
    return ref.watch(trainerMemberDetailRepositoryProvider).loadDetail(memberId);
  }

  void selectMetric(TrainerMetric metric) => state = state.copyWith(selectedMetric: metric);
}
