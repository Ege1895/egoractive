import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_member_detail.dart';
import '../service/admin_member_detail_service.dart';

part 'admin_member_detail_repository.g.dart';

abstract interface class AdminMemberDetailRepository {
  AdminMemberDetail loadDetail(String memberId);
}

class AdminMemberDetailRepositoryImpl implements AdminMemberDetailRepository {
  const AdminMemberDetailRepositoryImpl(this._service);

  final AdminMemberDetailService _service;

  @override
  AdminMemberDetail loadDetail(String memberId) => _service.loadDetail(memberId);
}

@riverpod
AdminMemberDetailRepository adminMemberDetailRepository(AdminMemberDetailRepositoryRef ref) {
  return AdminMemberDetailRepositoryImpl(ref.watch(adminMemberDetailServiceProvider));
}
