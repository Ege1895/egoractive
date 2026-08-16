import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_member_summary.dart';

/// `users/{uid}` (role=member) dokümanını [AdminMemberSummary]'ye çevirir.
/// Hem canlı akış tabanlı [AdminMembersController] hem sayfalı
/// [AdminMemberListController] aynı eşlemeyi kullanır.
AdminMemberSummary adminMemberSummaryFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data();
  final name = (data['name'] as String?)?.trim() ?? '';
  final remainingSessions = (data['remainingSessions'] as num?)?.toInt() ?? 0;
  final packageEndDateIso = data['packageEndDate'] as String?;
  final packageEndDate = packageEndDateIso == null ? null : DateTime.tryParse(packageEndDateIso);
  return AdminMemberSummary(
    id: doc.id,
    initials: _initialsFor(name),
    name: name,
    phone: (data['phoneNumber'] as String?) ?? '',
    trainerName: (data['trainerName'] as String?) ?? '',
    remainingSessions: remainingSessions,
    packageEndDate: packageEndDate == null ? '—' : '${packageEndDate.day}.${packageEndDate.month}.${packageEndDate.year}',
    status: remainingSessions > 0 ? MemberPackageStatus.active : MemberPackageStatus.none,
  );
}

String _initialsFor(String name) {
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}
