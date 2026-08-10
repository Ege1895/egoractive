import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/report_recipients.dart';
import '../repository/report_recipients_repository.dart';

part 'report_recipients_controller.g.dart';

@riverpod
Stream<ReportRecipients> _recipientsForGym(_RecipientsForGymRef ref, String gymId) {
  return ref.watch(reportRecipientsRepositoryProvider).watchRecipients(gymId);
}

/// F5-2 — haftalık salon/muhasebe raporlarının gönderileceği e-postalar.
@riverpod
class ReportRecipientsController extends _$ReportRecipientsController {
  @override
  ReportRecipients build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return const ReportRecipients();
    return ref.watch(_recipientsForGymProvider(gymId)).valueOrNull ?? const ReportRecipients();
  }

  Future<void> save(ReportRecipients recipients) async {
    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) return;
    await ref.read(reportRecipientsRepositoryProvider).saveRecipients(gymId, recipients);
  }
}
