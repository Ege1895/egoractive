import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/dashboard_report.dart';
import '../domain/report_snapshot.dart';

part 'report_pdf_export_service.g.dart';

/// F5-10'daki metin etiketleri — RC'den okunması gereken statik metinler
/// (bkz. proje hardcode kuralı) UI katmanında toplanıp buraya taşınır; bu
/// servis sadece render eder, RC'ye kendisi erişmez.
class ReportPdfLabels {
  const ReportPdfLabels({
    required this.documentTitle,
    required this.totalSessions,
    required this.completedSessions,
    required this.cancelledSessions,
    required this.estimatedRevenue,
    required this.totalExpenses,
    required this.net,
    required this.metricColumn,
    required this.valueColumn,
    required this.trainerPerformanceSection,
    required this.trainerColumn,
  });

  final String documentTitle;
  final String totalSessions;
  final String completedSessions;
  final String cancelledSessions;
  final String estimatedRevenue;
  final String totalExpenses;
  final String net;
  final String metricColumn;
  final String valueColumn;
  final String trainerPerformanceSection;
  final String trainerColumn;
}

/// F5-10 — geçmiş bir rapor snapshot'ından (F5-7/F5-8) cihazda PDF üretir;
/// sunucu tarafında (Cloud Functions) hiçbir PDF üretimi yapılmaz. Karar
/// gerekçesi görev listesindeki F5-7..F5-10 notunda: Puppeteer/headless
/// Chrome tabanlı sunucu üretimi yüksek bellek/cold-start maliyeti getirir
/// ve çoğu otomatik üretilen PDF hiç açılmaz.
class ReportPdfExportService {
  const ReportPdfExportService();

  Future<Uint8List> buildPdf(
    ReportSnapshot snapshot,
    ReportPdfLabels labels,
  ) async {
    final fontData = await rootBundle.load(
      'assets/fonts/IBMPlexSans-Variable.ttf',
    );
    final font = pw.Font.ttf(fontData);
    final report = snapshot.report;

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font, bold: font),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              labels.documentTitle,
              style: const pw.TextStyle(fontSize: 20),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              report.monthLabel,
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 16),
            _metricsTable(report, labels),
            if (report.trainerPerformance.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text(
                labels.trainerPerformanceSection,
                style: const pw.TextStyle(fontSize: 13),
              ),
              pw.SizedBox(height: 8),
              _trainerTable(report, labels),
            ],
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// PDF'i cihazda üretip sistem paylaş/kaydet sayfasını açar — network
  /// isteği yok, veri zaten [snapshot] içinde hazır.
  Future<void> share(ReportSnapshot snapshot, ReportPdfLabels labels) async {
    final bytes = await buildPdf(snapshot, labels);
    final dateSuffix = snapshot.periodStart.toIso8601String().substring(0, 10);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'rapor_${snapshot.period.name}_$dateSuffix.pdf',
    );
  }

  pw.Widget _metricsTable(DashboardReport report, ReportPdfLabels labels) {
    return pw.TableHelper.fromTextArray(
      headers: [labels.metricColumn, labels.valueColumn],
      data: [
        [labels.totalSessions, '${report.totalSessions}'],
        [labels.completedSessions, '${report.completedSessions}'],
        [labels.cancelledSessions, '${report.cancelledSessions}'],
        [labels.estimatedRevenue, '₺${report.estimatedRevenueTl}'],
        [labels.totalExpenses, '₺${report.totalExpensesTl}'],
        [labels.net, '₺${report.netTl}'],
      ],
    );
  }

  pw.Widget _trainerTable(DashboardReport report, ReportPdfLabels labels) {
    return pw.TableHelper.fromTextArray(
      headers: [
        labels.trainerColumn,
        labels.completedSessions,
        labels.totalSessions,
      ],
      data: [
        for (final trainer in report.trainerPerformance)
          [
            trainer.name,
            '${trainer.completedSessions}',
            '${trainer.totalSessions}',
          ],
      ],
    );
  }
}

@riverpod
ReportPdfExportService reportPdfExportService(ReportPdfExportServiceRef ref) =>
    const ReportPdfExportService();
