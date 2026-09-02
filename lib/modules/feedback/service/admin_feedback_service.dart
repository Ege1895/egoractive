import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_feedback_entry.dart';

part 'admin_feedback_service.g.dart';

const _monthNamesLong = {
  1: 'Ocak', 2: 'Şubat', 3: 'Mart', 4: 'Nisan', 5: 'Mayıs', 6: 'Haziran',
  7: 'Temmuz', 8: 'Ağustos', 9: 'Eylül', 10: 'Ekim', 11: 'Kasım', 12: 'Aralık',
};

/// F5-4 — `feedback` koleksiyonu (gymId, memberId, memberName, trainerId,
/// trainerName, stars, comment, createdAt). Sadece stüdyo yönetimi
/// (admin) görür; antrenöre hiç açılmıyor (F5-4 gizlilik notu).
class AdminFeedbackService {
  const AdminFeedbackService();

  /// [month] gösterilecek ayın herhangi bir günü olabilir; ayın ilk gününe
  /// normalize edilir.
  ///
  /// Önceden salonun TÜM geri bildirimleri limitsiz bir canlı listener ile
  /// çekiliyordu — yüzlerce kayıtta hem liste okunmaz hale geliyor hem her
  /// ekran açılışında bütün koleksiyon okunuyordu (F10 performans
  /// analizinde de işaretlenmişti). Artık sorgu tek bir ayla sınırlı;
  /// `gymId + createdAt` composite index'i zaten mevcut.
  ///
  /// `average`/`starCounts`/`totalCount` de artık SEÇİLİ AYA ait — admin
  /// ana ekranı da bu özeti kullanıyor ve orası zaten "Eylül 2026 özeti"
  /// gibi ay bazlı, dolayısıyla tutarlı.
  Stream<AdminFeedbackSummary> watchSummary(String gymId, DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final monthEnd = DateTime(month.year, month.month + 1, 1);

    return FirebaseFirestore.instance
        .collection('feedback')
        .where('gymId', isEqualTo: gymId)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(monthEnd))
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.toList()
        ..sort((a, b) {
          final aTime = a.data()['createdAt'] as Timestamp?;
          final bTime = b.data()['createdAt'] as Timestamp?;
          if (aTime == null || bTime == null) return 0;
          return bTime.compareTo(aTime);
        });

      final starCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      var totalStars = 0;
      for (final doc in docs) {
        final stars = (doc.data()['stars'] as num?)?.toInt() ?? 0;
        if (stars < 1 || stars > 5) continue;
        starCounts[stars] = (starCounts[stars] ?? 0) + 1;
        totalStars += stars;
      }

      return AdminFeedbackSummary(
        average: docs.isEmpty ? 0 : totalStars / docs.length,
        totalCount: docs.length,
        starCounts: starCounts,
        entries: docs.map(_toEntry).toList(),
      );
    });
  }

  AdminFeedbackEntry _toEntry(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final memberName = (data['memberName'] as String?) ?? '';
    final trainerName = (data['trainerName'] as String?) ?? '';
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
    final dateLabel = createdAt == null ? '' : '${createdAt.day} ${_monthNamesLong[createdAt.month]}';

    return AdminFeedbackEntry(
      id: doc.id,
      initials: _initials(memberName),
      memberName: memberName,
      meta: trainerName.isEmpty ? dateLabel : '$dateLabel · $trainerName',
      stars: (data['stars'] as num?)?.toInt() ?? 0,
      comment: (data['comment'] as String?) ?? '',
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

@riverpod
AdminFeedbackService adminFeedbackService(AdminFeedbackServiceRef ref) => const AdminFeedbackService();
