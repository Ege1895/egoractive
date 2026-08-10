import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/report_recipients.dart';
import '../service/report_recipients_service.dart';

part 'report_recipients_repository.g.dart';

abstract interface class ReportRecipientsRepository {
  Stream<ReportRecipients> watchRecipients(String gymId);
  Future<void> saveRecipients(String gymId, ReportRecipients recipients);
}

class ReportRecipientsRepositoryImpl implements ReportRecipientsRepository {
  const ReportRecipientsRepositoryImpl(this._service);

  final ReportRecipientsService _service;

  @override
  Stream<ReportRecipients> watchRecipients(String gymId) => _service.watchRecipients(gymId);

  @override
  Future<void> saveRecipients(String gymId, ReportRecipients recipients) => _service.saveRecipients(gymId, recipients);
}

@riverpod
ReportRecipientsRepository reportRecipientsRepository(ReportRecipientsRepositoryRef ref) {
  return ReportRecipientsRepositoryImpl(ref.watch(reportRecipientsServiceProvider));
}
