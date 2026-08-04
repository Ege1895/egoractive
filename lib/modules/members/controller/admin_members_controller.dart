import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_member_summary.dart';
import '../repository/admin_members_repository.dart';

part 'admin_members_controller.g.dart';

@riverpod
class AdminMembersController extends _$AdminMembersController {
  @override
  List<AdminMemberSummary> build() => ref.watch(adminMembersRepositoryProvider).loadMembers();

  void addMember(AdminMemberSummary member) => state = [...state, member];
}
