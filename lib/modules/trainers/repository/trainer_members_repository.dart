import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_member_summary.dart';
import '../service/trainer_members_service.dart';

part 'trainer_members_repository.g.dart';

abstract interface class TrainerMembersRepository {
  List<TrainerMemberSummary> loadMembers();
}

class TrainerMembersRepositoryImpl implements TrainerMembersRepository {
  const TrainerMembersRepositoryImpl(this._service);

  final TrainerMembersService _service;

  @override
  List<TrainerMemberSummary> loadMembers() => _service.loadMembers();
}

@riverpod
TrainerMembersRepository trainerMembersRepository(TrainerMembersRepositoryRef ref) {
  return TrainerMembersRepositoryImpl(ref.watch(trainerMembersServiceProvider));
}
