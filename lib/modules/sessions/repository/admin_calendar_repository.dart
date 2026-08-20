import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_calendar_state.dart';
import '../service/admin_calendar_service.dart';

part 'admin_calendar_repository.g.dart';

abstract interface class AdminCalendarRepository {
  AdminCalendarState loadInitial();
}

class AdminCalendarRepositoryImpl implements AdminCalendarRepository {
  const AdminCalendarRepositoryImpl(this._service);

  final AdminCalendarService _service;

  @override
  AdminCalendarState loadInitial() => _service.loadInitial();
}

@riverpod
AdminCalendarRepository adminCalendarRepository(
  AdminCalendarRepositoryRef ref,
) {
  return AdminCalendarRepositoryImpl(ref.watch(adminCalendarServiceProvider));
}
