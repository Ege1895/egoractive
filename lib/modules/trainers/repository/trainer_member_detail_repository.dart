import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_member_detail.dart';
import '../service/trainer_member_detail_service.dart';

part 'trainer_member_detail_repository.g.dart';

abstract interface class TrainerMemberDetailRepository {
  TrainerMemberDetail loadDetail(String memberId);
}

class TrainerMemberDetailRepositoryImpl implements TrainerMemberDetailRepository {
  const TrainerMemberDetailRepositoryImpl(this._service);

  final TrainerMemberDetailService _service;

  @override
  TrainerMemberDetail loadDetail(String memberId) => _service.loadDetail(memberId);
}

@riverpod
TrainerMemberDetailRepository trainerMemberDetailRepository(TrainerMemberDetailRepositoryRef ref) {
  return TrainerMemberDetailRepositoryImpl(ref.watch(trainerMemberDetailServiceProvider));
}
