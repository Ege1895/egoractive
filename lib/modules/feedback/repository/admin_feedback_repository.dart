import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_feedback_entry.dart';
import '../service/admin_feedback_service.dart';

part 'admin_feedback_repository.g.dart';

abstract interface class AdminFeedbackRepository {
  Stream<AdminFeedbackSummary> watchSummary(String gymId);
}

class AdminFeedbackRepositoryImpl implements AdminFeedbackRepository {
  const AdminFeedbackRepositoryImpl(this._service);

  final AdminFeedbackService _service;

  @override
  Stream<AdminFeedbackSummary> watchSummary(String gymId) => _service.watchSummary(gymId);
}

@riverpod
AdminFeedbackRepository adminFeedbackRepository(AdminFeedbackRepositoryRef ref) {
  return AdminFeedbackRepositoryImpl(ref.watch(adminFeedbackServiceProvider));
}
