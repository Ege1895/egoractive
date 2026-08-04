import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/sessions_state.dart';
import '../service/sessions_service.dart';

part 'sessions_repository.g.dart';

abstract interface class SessionsRepository {
  SessionsState loadInitial();
}

class SessionsRepositoryImpl implements SessionsRepository {
  const SessionsRepositoryImpl(this._service);

  final SessionsService _service;

  @override
  SessionsState loadInitial() => _service.loadInitial();
}

@riverpod
SessionsRepository sessionsRepository(SessionsRepositoryRef ref) {
  return SessionsRepositoryImpl(ref.watch(sessionsServiceProvider));
}
