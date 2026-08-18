import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_member_detail.dart';
import '../domain/admin_member_detail_mapper.dart';
import '../service/admin_member_detail_service.dart';

part 'admin_member_detail_repository.g.dart';

abstract interface class AdminMemberDetailRepository {
  Stream<AdminMemberDetail> watchDetail(String memberId);
}

class AdminMemberDetailRepositoryImpl implements AdminMemberDetailRepository {
  const AdminMemberDetailRepositoryImpl(this._service);

  final AdminMemberDetailService _service;

  @override
  Stream<AdminMemberDetail> watchDetail(String memberId) {
    return _service.watchMemberDoc(memberId).map((doc) {
      if (!doc.exists) return adminMemberDetailNotFoundPlaceholder(memberId);
      return adminMemberDetailFromDoc(doc);
    });
  }
}

@riverpod
AdminMemberDetailRepository adminMemberDetailRepository(
  AdminMemberDetailRepositoryRef ref,
) {
  return AdminMemberDetailRepositoryImpl(
    ref.watch(adminMemberDetailServiceProvider),
  );
}
