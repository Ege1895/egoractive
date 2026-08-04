import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_home_state.dart';
import '../repository/admin_home_repository.dart';

part 'admin_home_controller.g.dart';

@riverpod
class AdminHomeController extends _$AdminHomeController {
  @override
  AdminHomeState build() => ref.watch(adminHomeRepositoryProvider).loadInitial();
}
