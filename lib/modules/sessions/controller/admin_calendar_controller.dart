import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_calendar_state.dart';
import '../repository/admin_calendar_repository.dart';

part 'admin_calendar_controller.g.dart';

@riverpod
class AdminCalendarController extends _$AdminCalendarController {
  @override
  AdminCalendarState build() => ref.watch(adminCalendarRepositoryProvider).loadInitial();

  void selectDate(DateTime date) => state = state.copyWith(selectedDate: date);
}
