import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../trainers/domain/trainer_metric.dart';
import '../domain/admin_member_detail.dart';
import '../repository/admin_member_detail_repository.dart';

part 'admin_member_detail_controller.g.dart';

@riverpod
class AdminMemberDetailController extends _$AdminMemberDetailController {
  @override
  AdminMemberDetail build(String memberId) {
    return ref.watch(adminMemberDetailRepositoryProvider).loadDetail(memberId);
  }

  void selectMetric(TrainerMetric metric) => state = state.copyWith(selectedMetric: metric);
}
