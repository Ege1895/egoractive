import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/admin_feedback_entry.dart';
import '../repository/admin_feedback_repository.dart';

part 'admin_feedback_controller.g.dart';

const _empty = AdminFeedbackSummary(average: 0, totalCount: 0, starCounts: {}, entries: []);

@riverpod
Stream<AdminFeedbackSummary> _feedbackForGym(_FeedbackForGymRef ref, String gymId) {
  return ref.watch(adminFeedbackRepositoryProvider).watchSummary(gymId);
}

@riverpod
class AdminFeedbackController extends _$AdminFeedbackController {
  @override
  AdminFeedbackSummary build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return _empty;
    return ref.watch(_feedbackForGymProvider(gymId)).valueOrNull ?? _empty;
  }
}
