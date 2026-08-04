import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_member_summary.dart';
import '../service/admin_members_service.dart';

part 'admin_members_repository.g.dart';

abstract interface class AdminMembersRepository {
  List<AdminMemberSummary> loadMembers();
}

class AdminMembersRepositoryImpl implements AdminMembersRepository {
  const AdminMembersRepositoryImpl(this._service);

  final AdminMembersService _service;

  @override
  List<AdminMemberSummary> loadMembers() => _service.loadMembers();
}

@riverpod
AdminMembersRepository adminMembersRepository(AdminMembersRepositoryRef ref) {
  return AdminMembersRepositoryImpl(ref.watch(adminMembersServiceProvider));
}
