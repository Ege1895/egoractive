import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_feedback_entry.dart';
import '../repository/admin_feedback_repository.dart';

part 'admin_feedback_controller.g.dart';

@riverpod
class AdminFeedbackController extends _$AdminFeedbackController {
  @override
  AdminFeedbackSummary build() => ref.watch(adminFeedbackRepositoryProvider).loadSummary();
}
