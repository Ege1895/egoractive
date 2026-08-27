import 'package:freezed_annotation/freezed_annotation.dart';

import 'dashboard_report.dart';

part 'report_snapshot.freezed.dart';

/// F5-9 — Raporlar ekranındaki haftalık/aylık filtre.
enum ReportPeriod { weekly, monthly }

/// F5-7'de scheduled fonksiyonların yazdığı `reportSnapshots` dokümanının
/// client tarafı karşılığı. [report] alanı canlı dashboard'daki
/// [DashboardReport] ile aynı şekilde modellenir (`monthLabel` burada
/// snapshot'ın periyot etiketini taşır) — böylece F5-9'daki detay görünümü,
/// F5-1'in metrik/antrenör chart widget'larını değişiklik yapmadan yeniden
/// kullanabilir.
@freezed
class ReportSnapshot with _$ReportSnapshot {
  const factory ReportSnapshot({
    required String id,
    required ReportPeriod period,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DashboardReport report,
  }) = _ReportSnapshot;
}
