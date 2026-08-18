import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_member_detail.dart';
import '../domain/trainer_member_detail_mapper.dart';
import '../service/trainer_member_detail_service.dart';

part 'trainer_member_detail_repository.g.dart';

abstract interface class TrainerMemberDetailRepository {
  Stream<TrainerMemberDetail> watchDetail(String memberId);
}

class TrainerMemberDetailRepositoryImpl
    implements TrainerMemberDetailRepository {
  const TrainerMemberDetailRepositoryImpl(this._service);

  final TrainerMemberDetailService _service;

  @override
  Stream<TrainerMemberDetail> watchDetail(String memberId) {
    return _service.watchMemberDoc(memberId).map((doc) {
      if (!doc.exists) return trainerMemberDetailNotFoundPlaceholder(memberId);
      return trainerMemberDetailFromDoc(doc);
    });
  }
}

@riverpod
TrainerMemberDetailRepository trainerMemberDetailRepository(
  TrainerMemberDetailRepositoryRef ref,
) {
  return TrainerMemberDetailRepositoryImpl(
    ref.watch(trainerMemberDetailServiceProvider),
  );
}
