import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../domain/admin_member_summary.dart';
import '../repository/admin_members_repository.dart';

part 'admin_members_controller.g.dart';

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [AdminMembersController] mock listeye düşer.
@riverpod
Stream<List<AdminMemberSummary>> _membersForGym(_MembersForGymRef ref, String gymId) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('gymId', isEqualTo: gymId)
      .where('role', isEqualTo: 'member')
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_toSummary).toList());
}

AdminMemberSummary _toSummary(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

/// F2-2 — aktif salonun üyelerini gerçek zamanlı listeler. Dış arayüz
/// bilerek senkron (`List<AdminMemberSummary>`) tutuldu — panel/servis
/// tüketicileri (liste, detay, bildirim gönderme) `AsyncValue` bilmek
/// zorunda değil; Firestore akışı burada sarmalanıyor.
@riverpod
class AdminMembersController extends _$AdminMembersController {
  @override
  List<AdminMemberSummary> build() {
    final gymId = ref.watch(activeGymIdProvider).valueOrNull;
    if (gymId == null) {
      return ref.watch(adminMembersRepositoryProvider).loadMembers();
    }
    return ref.watch(_membersForGymProvider(gymId)).valueOrNull ?? const [];
  }
}
