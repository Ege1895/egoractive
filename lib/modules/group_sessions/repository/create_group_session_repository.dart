import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/create_group_session_form.dart';
import '../service/create_group_session_service.dart';

part 'create_group_session_repository.g.dart';

abstract interface class CreateGroupSessionRepository {
  CreateGroupSessionForm loadInitial();
}

class CreateGroupSessionRepositoryImpl implements CreateGroupSessionRepository {
  const CreateGroupSessionRepositoryImpl(this._service);

  final CreateGroupSessionService _service;

  @override
  CreateGroupSessionForm loadInitial() => _service.loadInitial();
}

@riverpod
CreateGroupSessionRepository createGroupSessionRepository(CreateGroupSessionRepositoryRef ref) {
  return CreateGroupSessionRepositoryImpl(ref.watch(createGroupSessionServiceProvider));
}
