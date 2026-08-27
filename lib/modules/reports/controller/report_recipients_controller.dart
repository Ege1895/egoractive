import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/report_recipients.dart';
import '../repository/report_recipients_repository.dart';

part 'report_recipients_controller.g.dart';

@riverpod
Stream<ReportRecipients> _recipientsForGym(
  _RecipientsForGymRef ref,
  String gymId,
) {
  return ref.watch(reportRecipientsRepositoryProvider).watchRecipients(gymId);
}

/// F5-2/F5-15 — haftalık/aylık salon raporunun gönderileceği e-posta.
@riverpod
class ReportRecipientsController extends _$ReportRecipientsController {
  @override
  ReportRecipients build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) return const ReportRecipients();
    return ref.watch(_recipientsForGymProvider(gymId)).valueOrNull ??
        const ReportRecipients();
  }

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Önceki sürüm ne e-posta formatını doğruluyordu ne de yazma hatasını
  /// yakalıyordu — buton fire-and-forget çağrılıyordu, başarısız olursa
  /// hiçbir geri bildirim yoktu.
  Future<void> save(ReportRecipients recipients) async {
    if (recipients.gymReportEmail.isNotEmpty &&
        !_emailPattern.hasMatch(recipients.gymReportEmail)) {
      state = state.copyWith(errorMessage: 'Rapor e-postası geçerli değil.');
      return;
    }

    final gymId = ref.read(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      state = state.copyWith(errorMessage: 'Aktif bir salon bulunamadı.');
      return;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await ref
          .read(reportRecipientsRepositoryProvider)
          .saveRecipients(gymId, recipients);
      state = state.copyWith(isSaving: false);
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Kaydedilemedi, tekrar dene.',
      );
    }
  }
}
