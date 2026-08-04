import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_member_summary.dart';
import '../repository/trainer_members_repository.dart';

part 'trainer_members_controller.g.dart';

@riverpod
class TrainerMembersController extends _$TrainerMembersController {
  @override
  List<TrainerMemberSummary> build() => ref.watch(trainerMembersRepositoryProvider).loadMembers();
}
