import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_member_summary.dart';

/// `users/{uid}` (role=member) dokümanını [AdminMemberSummary]'ye çevirir.
/// Hem canlı akış tabanlı [AdminMembersController] hem sayfalı
/// [AdminMemberListController] aynı eşlemeyi kullanır.
///
/// "Kalan ders" — henüz PLANLANMAMIŞ hak (`remainingSessions`, seans
/// oluşturulduğunda düşülür) + hâlâ takvimde bekleyen, tamamlanmamış
/// seans sayısı (`plannedSessionsCount`) toplamı. Sadece gerçekten
/// tamamlanmış dersler bu sayıdan düşer — üye 12 seanslık paket aldıysa,
/// 6'sı takvime girilip 3'ü tamamlanmışsa burada 9 gösterilir, 3 değil
/// (önceden sadece `remainingSessions`, yani planlanmış seanslar da dahil
/// tüm rezervasyonları düşen 3 gösteriliyordu — bir üye paketinin TÜMÜ
/// takvime girildiğinde "Paketi yok" filtresine hatalı düşüyordu).
AdminMemberSummary adminMemberSummaryFromDoc(
  QueryDocumentSnapshot<Map<String, dynamic>> doc, {
  required int endingSoonThreshold,
}) {
  final data = doc.data();
  final name = (data['name'] as String?)?.trim() ?? '';
  final unplanned = (data['remainingSessions'] as num?)?.toInt() ?? 0;
  final planned = (data['plannedSessionsCount'] as num?)?.toInt() ?? 0;
  final totalRemaining = unplanned + planned;
  final packageEndDateIso = data['packageEndDate'] as String?;
  final packageEndDate = packageEndDateIso == null
      ? null
      : DateTime.tryParse(packageEndDateIso);
  return AdminMemberSummary(
    id: doc.id,
    initials: _initialsFor(name),
    name: name,
    phone: (data['phoneNumber'] as String?) ?? '',
    trainerName: (data['trainerName'] as String?) ?? '',
    remainingSessions: totalRemaining,
    packageEndDate: packageEndDate == null
        ? '—'
        : '${packageEndDate.day}.${packageEndDate.month}.${packageEndDate.year}',
    status: totalRemaining <= 0
        ? MemberPackageStatus.none
        : totalRemaining <= endingSoonThreshold
        ? MemberPackageStatus.endingSoon
        : MemberPackageStatus.active,
  );
}

String _initialsFor(String name) {
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}
