import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_home_state.dart';
import '../service/admin_home_service.dart';

part 'admin_home_repository.g.dart';

abstract interface class AdminHomeRepository {
  AdminHomeState loadInitial();
}

class AdminHomeRepositoryImpl implements AdminHomeRepository {
  const AdminHomeRepositoryImpl(this._service);

  final AdminHomeService _service;

  @override
  AdminHomeState loadInitial() => _service.loadInitial();
}

@riverpod
AdminHomeRepository adminHomeRepository(AdminHomeRepositoryRef ref) {
  return AdminHomeRepositoryImpl(ref.watch(adminHomeServiceProvider));
}
