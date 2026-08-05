import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_group_session.dart';
import '../repository/admin_group_sessions_repository.dart';

part 'admin_group_sessions_controller.g.dart';

@riverpod
class AdminGroupSessionsController extends _$AdminGroupSessionsController {
  @override
  List<AdminGroupSession> build() => ref.watch(adminGroupSessionsRepositoryProvider).loadGroupSessions();
}
