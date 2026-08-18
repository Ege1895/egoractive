import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../service/admin_home_service.dart';

part 'admin_home_repository.g.dart';

abstract interface class AdminHomeRepository {
  Future<DuePaymentsSummary> loadDuePaymentsSummary(String gymId);
}

class AdminHomeRepositoryImpl implements AdminHomeRepository {
  const AdminHomeRepositoryImpl(this._service);

  final AdminHomeService _service;

  @override
  Future<DuePaymentsSummary> loadDuePaymentsSummary(String gymId) =>
      _service.loadDuePaymentsSummary(gymId);
}

@riverpod
AdminHomeRepository adminHomeRepository(AdminHomeRepositoryRef ref) {
  return AdminHomeRepositoryImpl(ref.watch(adminHomeServiceProvider));
}
