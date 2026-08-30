import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/utils/thousands_input_formatter.dart';
import '../domain/dashboard_report.dart';
import '../domain/report_snapshot.dart';

part 'report_pdf_export_service.g.dart';

const _ink = PdfColor.fromInt(0xFF12181F);
const _muted = PdfColor.fromInt(0xFF5F6B7A);
const _faint = PdfColor.fromInt(0xFF93A0B0);
const _line = PdfColor.fromInt(0xFFE7ECF3);
const _lineSoft = PdfColor.fromInt(0xFFF1F4F8);
const _brand = PdfColor.fromInt(0xFF05A6FA);
const _good = PdfColor.fromInt(0xFF17916A);
const _goodWash = PdfColor.fromInt(0xFFE5F6EE);
const _bad = PdfColor.fromInt(0xFFD14B3F);
const _badWash = PdfColor.fromInt(0xFFFDEBE9);
const _amber = PdfColor.fromInt(0xFFC97A1B);
const _other = PdfColor.fromInt(0xFFC7CFDA);
const _fill = PdfColor.fromInt(0xFFDCE6F2);

/// F5-21'deki metin etiketleri — RC'den okunması gereken statik metinler
/// (bkz. proje hardcode kuralı) UI katmanında toplanıp buraya taşınır; bu
/// servis sadece render eder, RC'ye kendisi erişmez. Alanlar
/// `functions/src/shared/report-email-template.ts`'teki `COPY` ile
/// birebir eşleşir — PDF, mail template'iyle aynı bölümleri gösterir.
class ReportPdfLabels {
  const ReportPdfLabels({
    required this.documentTitle,
    required this.heroPositiveTemplate,
    required this.heroNegativeTemplate,
    required this.heroSubPositive,
    required this.heroSubNegative,
    required this.sessionsTitle,
    required this.individualSessionsLabel,
    required this.duetSessionsLabel,
    required this.totalSessions,
    required this.completed,
    required this.cancelled,
    required this.other,
    required this.groupEventsTitle,
    required this.groupSessionsLabel,
    required this.eventsLabel,
    required this.sessionsUnit,
    required this.eventsUnit,
    required this.attendanceTemplate,
    required this.trainersTitle,
    required this.trainersEmpty,
    required this.completedShort,
    required this.cancelledShort,
    required this.totalShort,
    required this.soloPillLabel,
    required this.duetPillLabel,
    required this.groupPillLabel,
    required this.completionRateTemplate,
    required this.packagesTitle,
    required this.packagesEmpty,
    required this.salesUnit,
    required this.financeTitle,
    required this.revenue,
    required this.expenses,
    required this.netProfit,
    required this.netLoss,
    required this.footer,
  });

  final String documentTitle;
  final String heroPositiveTemplate;
  final String heroNegativeTemplate;
  final String heroSubPositive;
  final String heroSubNegative;
  final String sessionsTitle;
  final String individualSessionsLabel;
  final String duetSessionsLabel;
  final String totalSessions;
  final String completed;
  final String cancelled;
  final String other;
  final String groupEventsTitle;
  final String groupSessionsLabel;
  final String eventsLabel;
  final String sessionsUnit;
  final String eventsUnit;
  final String attendanceTemplate;
  final String trainersTitle;
  final String trainersEmpty;
  final String completedShort;
  final String cancelledShort;
  final String totalShort;
  final String soloPillLabel;
  final String duetPillLabel;
  final String groupPillLabel;
  final String completionRateTemplate;
  final String packagesTitle;
  final String packagesEmpty;
  final String salesUnit;
  final String financeTitle;
  final String revenue;
  final String expenses;
  final String netProfit;
  final String netLoss;
  final String footer;
}

class _Segment {
  const _Segment(this.value, this.color);

  final double value;
  final PdfColor color;
}

/// F5-10/F5-21 — geçmiş bir rapor snapshot'ından (F5-7/F5-8) cihazda, mail
/// template'iyle (F5-11) birebir aynı görünümde PDF üretir; sunucu
/// tarafında (Cloud Functions) hiçbir PDF üretimi yapılmaz — karar
/// gerekçesi görev listesindeki F5-7..F5-10 notunda. Mail'in aksine PDF
/// tek bir render motorunda (bu paket) üretildiğinden, mail'deki tablo
/// hücre genişliği hack'lerine gerek yok — bar'lar gerçek `Expanded`/`flex`
/// ile çiziliyor. Emoji/madalya kullanılmıyor: gömülü metin fontunun emoji
/// glifi yok, PDF'te boş kutucuk olarak görünürdü.
class ReportPdfExportService {
  const ReportPdfExportService();

  Future<Uint8List> buildPdf(
    ReportSnapshot snapshot,
    String gymName,
    ReportPdfLabels labels,
  ) async {
    final fontData = await rootBundle.load(
      'assets/fonts/IBMPlexSans-Variable.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final report = snapshot.report;
    final net = report.netTl;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _header(gymName, report.monthLabel),
          pw.SizedBox(height: 16),
          _heroBanner(net, labels),
          _sessionsSection(report, labels),
          _groupEventsSection(snapshot, labels),
          _trainersSection(report.trainerPerformance, labels),
          _packagesSection(snapshot.packages, labels),
          _financeSection(report, labels),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              labels.footer,
              style: pw.TextStyle(fontSize: 9, color: _faint),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  /// PDF'i cihazda üretip sistem paylaş/kaydet sayfasını açar — network
  /// isteği yok, veri zaten [snapshot] içinde hazır.
  Future<void> share(
    ReportSnapshot snapshot,
    String gymName,
    ReportPdfLabels labels,
  ) async {
    final bytes = await buildPdf(snapshot, gymName, labels);
    final dateSuffix = snapshot.periodStart.toIso8601String().substring(0, 10);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'rapor_${snapshot.period.name}_$dateSuffix.pdf',
    );
  }

  pw.Widget _header(String gymName, String periodLabel) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const pw.BoxDecoration(
        color: _brand,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'EGORACTIVE',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.white,
              letterSpacing: 1.4,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            gymName,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            periodLabel,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
          ),
        ],
      ),
    );
  }

  pw.Widget _heroBanner(int net, ReportPdfLabels labels) {
    final positive = net >= 0;
    final headline =
        (positive ? labels.heroPositiveTemplate : labels.heroNegativeTemplate)
            .replaceAll('{net}', _tl(net.abs()));
    final sub = positive ? labels.heroSubPositive : labels.heroSubNegative;
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: positive ? _goodWash : _badWash,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            headline,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(sub, style: const pw.TextStyle(fontSize: 9.5, color: _muted)),
        ],
      ),
    );
  }

  pw.Widget _card(String title, pw.Widget child) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 14),
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _line),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: _ink,
            ),
          ),
          pw.SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  pw.Widget _segBar(List<_Segment> segments, {double height = 9}) {
    final total = segments.fold<double>(0, (s, x) => s + x.value);
    final safeTotal = total <= 0 ? 1.0 : total;
    return pw.SizedBox(
      height: height,
      child: pw.Row(
        children: [
          for (final seg in segments)
            if (seg.value > 0)
              pw.Expanded(
                flex: (seg.value / safeTotal * 1000).round().clamp(1, 100000),
                child: pw.Container(height: height, color: seg.color),
              ),
        ],
      ),
    );
  }

  pw.Widget _legend(List<(PdfColor, int, String)> items) {
    return pw.Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        for (final (color, pct, label) in items)
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 7,
                height: 7,
                decoration: pw.BoxDecoration(
                  color: color,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 5),
              pw.Text(
                '%$pct $label',
                style: const pw.TextStyle(fontSize: 9, color: _muted),
              ),
            ],
          ),
      ],
    );
  }

  pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 3),
        padding: const pw.EdgeInsets.symmetric(vertical: 10),
        decoration: pw.BoxDecoration(
          color: _lineSoft,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 17,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 8.5, color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _sessionTypeBlock(
    String title,
    SessionTypeBreakdown breakdown,
    ReportPdfLabels labels,
  ) {
    final completedPct = _pct(breakdown.completed, breakdown.total);
    final cancelledPct = _pct(breakdown.cancelled, breakdown.total);
    final otherCount = (breakdown.total - breakdown.completed - breakdown.cancelled)
        .clamp(0, 1 << 30);
    final otherPct = (100 - completedPct - cancelledPct).clamp(0, 100);
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10.5,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _statBox(labels.totalSessions, '${breakdown.total}', _ink),
            _statBox(labels.completed, '${breakdown.completed}', _good),
            _statBox(labels.cancelled, '${breakdown.cancelled}', _bad),
          ],
        ),
        pw.SizedBox(height: 12),
        _segBar([
          _Segment(breakdown.completed.toDouble(), _good),
          _Segment(breakdown.cancelled.toDouble(), _bad),
          _Segment(otherCount.toDouble(), _other),
        ]),
        pw.SizedBox(height: 8),
        _legend([
          (_good, completedPct, labels.completed),
          (_bad, cancelledPct, labels.cancelled),
          (_other, otherPct, labels.other),
        ]),
      ],
    );
  }

  /// F7-x — "Ders Özeti" bölümü Birebir Seans ve Düet Dersi'ni ayrı
  /// bloklar olarak, her biri kendi tamamlanan/iptal kırılımıyla gösterir.
  /// Grup dersleri burada değil, `_groupEventsSection`'da kalır.
  pw.Widget _sessionsSection(DashboardReport report, ReportPdfLabels labels) {
    return _card(
      labels.sessionsTitle,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sessionTypeBlock(
            labels.individualSessionsLabel,
            report.individualSessions,
            labels,
          ),
          pw.SizedBox(height: 14),
          _sessionTypeBlock(
            labels.duetSessionsLabel,
            report.duetSessions,
            labels,
          ),
        ],
      ),
    );
  }

  pw.Widget _occupancyBlock(
    String label,
    int count,
    String unit,
    ReportOccupancy stats,
    ReportPdfLabels labels, {
    // F7-x — Grup Dersleri kartına eklenen tamamlanan/iptal satırı.
    // `groupSessions` koleksiyonunda bir iptal durumu tutulmadığından
    // (dersi iptal etme akışı yok) "tamamlanan" dönemde gerçekleşen tüm
    // dersler, "iptal" her zaman 0 — bkz. `_groupEventsSection`.
    (int completed, int cancelled)? completedCancelled,
  }) {
    final occPct = _pct(stats.attendance, stats.capacity);
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 3),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _lineSoft,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: _muted),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '$count $unit',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.SizedBox(height: 8),
            _segBar([
              _Segment(stats.attendance.toDouble(), _brand),
              _Segment(
                (stats.capacity - stats.attendance)
                    .clamp(0, 1 << 30)
                    .toDouble(),
                _fill,
              ),
            ], height: 7),
            pw.SizedBox(height: 6),
            pw.Text(
              labels.attendanceTemplate
                  .replaceAll('{attendance}', '${stats.attendance}')
                  .replaceAll('{capacity}', '${stats.capacity}')
                  .replaceAll('{pct}', '$occPct'),
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
            if (completedCancelled != null) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.only(top: 8),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: _line)),
                ),
                child: pw.Text(
                  '${completedCancelled.$1} ${labels.completedShort} · ${completedCancelled.$2} ${labels.cancelledShort}',
                  style: const pw.TextStyle(fontSize: 8, color: _muted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  pw.Widget _groupEventsSection(
    ReportSnapshot snapshot,
    ReportPdfLabels labels,
  ) {
    return _card(
      labels.groupEventsTitle,
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _occupancyBlock(
            labels.groupSessionsLabel,
            snapshot.groupSessions.count,
            labels.sessionsUnit,
            snapshot.groupSessions,
            labels,
            completedCancelled: (snapshot.groupSessions.count, 0),
          ),
          _occupancyBlock(
            labels.eventsLabel,
            snapshot.events.count,
            labels.eventsUnit,
            snapshot.events,
            labels,
          ),
        ],
      ),
    );
  }

  pw.Widget _pill(String label, int value, PdfColor color) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(right: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: pw.BoxDecoration(
        color: _lineSoft,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
      ),
      child: pw.Text(
        '$label $value',
        style: pw.TextStyle(fontSize: 7.5, color: color),
      ),
    );
  }

  pw.Widget _trainerRow(TrainerPerformance trainer, ReportPdfLabels labels) {
    final completedPct = _pct(trainer.completedSessions, trainer.totalSessions);
    final cancelledPct = _pct(trainer.cancelledSessions, trainer.totalSessions);
    final otherCount =
        (trainer.totalSessions -
                trainer.completedSessions -
                trainer.cancelledSessions)
            .clamp(0, 1 << 30);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                trainer.name,
                style: pw.TextStyle(
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
              pw.Text(
                '${trainer.completedSessions} ${labels.completedShort} · ${trainer.cancelledSessions} ${labels.cancelledShort} · ${trainer.totalSessions} ${labels.totalShort}',
                style: const pw.TextStyle(fontSize: 8.5, color: _muted),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          _segBar([
            _Segment(trainer.completedSessions.toDouble(), _good),
            _Segment(trainer.cancelledSessions.toDouble(), _bad),
            _Segment(otherCount.toDouble(), _other),
          ], height: 6),
          pw.SizedBox(height: 3),
          pw.Text(
            labels.completionRateTemplate
                .replaceAll('{completed}', '$completedPct')
                .replaceAll('{cancelled}', '$cancelledPct'),
            style: const pw.TextStyle(fontSize: 7.5, color: _faint),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              _pill(labels.soloPillLabel, trainer.soloSessions, _brand),
              _pill(labels.duetPillLabel, trainer.duetSessions, _brand),
              _pill(labels.groupPillLabel, trainer.groupSessions, _brand),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _trainersSection(
    List<TrainerPerformance> trainers,
    ReportPdfLabels labels,
  ) {
    if (trainers.isEmpty) {
      return _card(
        labels.trainersTitle,
        pw.Text(
          labels.trainersEmpty,
          style: const pw.TextStyle(fontSize: 9.5, color: _muted),
        ),
      );
    }
    final sorted = [...trainers]
      ..sort((a, b) => b.completedSessions.compareTo(a.completedSessions));
    return _card(
      labels.trainersTitle,
      pw.Column(
        children: [for (final trainer in sorted) _trainerRow(trainer, labels)],
      ),
    );
  }

  pw.Widget _packagesSection(
    List<ReportPackageSale> packages,
    ReportPdfLabels labels,
  ) {
    if (packages.isEmpty) {
      return _card(
        labels.packagesTitle,
        pw.Text(
          labels.packagesEmpty,
          style: const pw.TextStyle(fontSize: 9.5, color: _muted),
        ),
      );
    }
    final sorted = [...packages]..sort((a, b) => b.count.compareTo(a.count));
    final max = sorted.first.count == 0 ? 1 : sorted.first.count;
    return _card(
      labels.packagesTitle,
      pw.Column(
        children: [
          for (var i = 0; i < sorted.length; i++)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        '${i + 1}. ${sorted[i].packageName}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _ink,
                        ),
                      ),
                      pw.Text(
                        '${sorted[i].count} ${labels.salesUnit}',
                        style: const pw.TextStyle(fontSize: 9, color: _muted),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  _segBar([
                    _Segment(
                      sorted[i].count.toDouble().clamp(
                        max * 0.06,
                        double.infinity,
                      ),
                      _brand,
                    ),
                    _Segment(
                      (max - sorted[i].count).clamp(0, max).toDouble(),
                      _lineSoft,
                    ),
                  ], height: 6),
                ],
              ),
            ),
        ],
      ),
    );
  }

  pw.Widget _financeSection(DashboardReport report, ReportPdfLabels labels) {
    final revenue = report.estimatedRevenueTl;
    final expenses = report.totalExpensesTl;
    final net = report.netTl;
    final positive = net >= 0;
    final maxBar = (revenue > expenses ? revenue : expenses).clamp(1, 1 << 30);
    return _card(
      labels.financeTitle,
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labels.revenue,
                style: const pw.TextStyle(fontSize: 10, color: _muted),
              ),
              pw.Text(
                _tl(revenue),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _good,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          _segBar([
            _Segment(
              revenue.toDouble().clamp(maxBar * 0.04, double.infinity),
              _good,
            ),
            _Segment((maxBar - revenue).clamp(0, maxBar).toDouble(), _lineSoft),
          ], height: 6),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                labels.expenses,
                style: const pw.TextStyle(fontSize: 10, color: _muted),
              ),
              pw.Text(
                _tl(expenses),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: _amber,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          _segBar([
            _Segment(
              expenses.toDouble().clamp(maxBar * 0.04, double.infinity),
              _amber,
            ),
            _Segment(
              (maxBar - expenses).clamp(0, maxBar).toDouble(),
              _lineSoft,
            ),
          ], height: 6),
          pw.SizedBox(height: 12),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: pw.BoxDecoration(
              color: positive ? _goodWash : _badWash,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  positive ? labels.netProfit : labels.netLoss,
                  style: pw.TextStyle(
                    fontSize: 10.5,
                    fontWeight: pw.FontWeight.bold,
                    color: _ink,
                  ),
                ),
                pw.Text(
                  '${positive ? '+' : '-'}${_tl(net.abs())}',
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                    color: positive ? _good : _bad,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _tl(int amount) => '₺${formatThousands(amount)}';

  int _pct(int part, int total) =>
      total == 0 ? 0 : ((part / total) * 100).round();
}

@riverpod
ReportPdfExportService reportPdfExportService(ReportPdfExportServiceRef ref) =>
    const ReportPdfExportService();
