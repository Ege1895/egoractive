import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_recipients.freezed.dart';

/// F5-2/F5-15 — haftalık/aylık salon raporunun gönderileceği tek e-posta
/// adresi (mali özet de artık aynı mailin içinde — ayrı bir muhasebe
/// e-postası yok). Boş string = henüz ayarlanmamış, rapor gönderilmez.
@freezed
class ReportRecipients with _$ReportRecipients {
  const factory ReportRecipients({
    @Default('') String gymReportEmail,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _ReportRecipients;
}
