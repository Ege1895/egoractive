import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/member_package.dart';
import '../repository/package_repository.dart';

part 'package_controller.g.dart';

@riverpod
class PackageController extends _$PackageController {
  @override
  MemberPackage build() => ref.watch(packageRepositoryProvider).loadActivePackage();
}
