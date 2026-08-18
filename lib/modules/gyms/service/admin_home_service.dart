import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_home_service.g.dart';

class DuePaymentsSummary {
  const DuePaymentsSummary({required this.memberCount, required this.totalTl});

  final int memberCount;
  final int totalTl;

  static const empty = DuePaymentsSummary(memberCount: 0, totalTl: 0);
}

/// Aylık seans/ciro/antrenör performansı `DashboardReportService`
/// (reports modülü) tarafından zaten gerçek zamanlı hesaplanıyor —
/// `AdminHomeController` bunu tekrarlamak yerine doğrudan
/// `dashboardReportControllerProvider`'ı izliyor. Burada sadece bu panele
/// özel, o modülde karşılığı olmayan "ödemesi bekleyen üye" özeti var.
class AdminHomeService {
  const AdminHomeService();

  /// `memberPackages` dokümanında ayrı bir "ödeme vadesi" alanı yok — bu
  /// yüzden isim/tarih bazlı bir liste yerine, kalan borcu (`dueAmount`)
  /// pozitif olan üye sayısı + toplam tutar gösteriliyor (aggregate query,
  /// tüm dokümanları client'a çekmeden).
  Future<DuePaymentsSummary> loadDuePaymentsSummary(String gymId) async {
    final query = FirebaseFirestore.instance
        .collection('memberPackages')
        .where('gymId', isEqualTo: gymId)
        .where('dueAmount', isGreaterThan: 0);

    final results = await Future.wait([
      query.count().get(),
      query.aggregate(sum('dueAmount')).get(),
    ]);

    return DuePaymentsSummary(
      memberCount: results[0].count ?? 0,
      totalTl: (results[1].getSum('dueAmount') ?? 0).round(),
    );
  }
}

@riverpod
AdminHomeService adminHomeService(AdminHomeServiceRef ref) =>
    const AdminHomeService();
