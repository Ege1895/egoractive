import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_recipients.freezed.dart';

/// F5-2 — haftalık salon/muhasebe raporlarının gönderileceği e-posta
/// adresleri. Boş string = henüz ayarlanmamış, o rapor gönderilmez.
@freezed
class ReportRecipients with _$ReportRecipients {
  const factory ReportRecipients({
    @Default('') String gymReportEmail,
    @Default('') String accountingReportEmail,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _ReportRecipients;
}
