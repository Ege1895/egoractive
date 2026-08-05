import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_group_session.dart';
import '../service/admin_group_sessions_service.dart';

part 'admin_group_sessions_repository.g.dart';

abstract interface class AdminGroupSessionsRepository {
  List<AdminGroupSession> loadGroupSessions();
}

class AdminGroupSessionsRepositoryImpl implements AdminGroupSessionsRepository {
  const AdminGroupSessionsRepositoryImpl(this._service);

  final AdminGroupSessionsService _service;

  @override
  List<AdminGroupSession> loadGroupSessions() => _service.loadGroupSessions();
}

@riverpod
AdminGroupSessionsRepository adminGroupSessionsRepository(AdminGroupSessionsRepositoryRef ref) {
  return AdminGroupSessionsRepositoryImpl(ref.watch(adminGroupSessionsServiceProvider));
}
