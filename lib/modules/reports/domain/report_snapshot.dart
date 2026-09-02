import 'package:freezed_annotation/freezed_annotation.dart';

import 'dashboard_report.dart';

part 'report_snapshot.freezed.dart';

/// F5-9 — Raporlar ekranındaki haftalık/aylık filtre.
enum ReportPeriod { weekly, monthly }

/// F5-11 — dönem içinde satın alınan bir paketin satış adedi
/// (`functions/src/shared/report-extras-stats.ts`'teki `PackageSaleCount`
/// ile aynı şekil).
@freezed
class ReportPackageSale with _$ReportPackageSale {
  const factory ReportPackageSale({
    required String packageName,
    required int count,
  }) = _ReportPackageSale;
}

/// F5-11 — grup dersi/etkinlik doluluk özeti (`OccupancyStats` ile aynı
/// şekil): kaç tanesi yapıldı, toplam kontenjanı ve gerçek katılımı neydi.
@freezed
class ReportOccupancy with _$ReportOccupancy {
  const factory ReportOccupancy({
    required int count,
    required int capacity,
    required int attendance,
  }) = _ReportOccupancy;

  const ReportOccupancy._();

  static const empty = ReportOccupancy(count: 0, capacity: 0, attendance: 0);

  double get occupancyRatio => capacity == 0 ? 0 : attendance / capacity;
}

/// F5-7'de scheduled fonksiyonların yazdığı `reportSnapshots` dokümanının
/// client tarafı karşılığı. [report] alanı canlı dashboard'daki
/// [DashboardReport] ile aynı şekilde modellenir (`monthLabel` burada
/// snapshot'ın periyot etiketini taşır) — böylece F5-9'daki detay görünümü,
/// F5-1'in metrik/antrenör chart widget'larını değişiklik yapmadan yeniden
/// kullanabilir. [packages]/[groupSessions]/[events] F5-11'de mail
/// template'i için eklenen alanlar — sadece `report` içine değil, ayrı
/// tutuluyor çünkü [DashboardReport] canlı özetle de paylaşılıyor ve o akış
/// bunları henüz hesaplamıyor. [currency] F9-4'te eklendi: salonun para
/// birimi kilidi kaldırılırsa diye, raporun yazıldığı ANDAKİ para birimini
/// (o zamanki `gyms/{gymId}.currency`) tutar — aktif salonun güncel para
/// birimiyle karıştırılmamalı.
@freezed
class ReportSnapshot with _$ReportSnapshot {
  const factory ReportSnapshot({
    required String id,
    required ReportPeriod period,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DashboardReport report,
    required List<ReportPackageSale> packages,
    required ReportOccupancy groupSessions,
    required ReportOccupancy events,
    required String currency,
  }) = _ReportSnapshot;
}
