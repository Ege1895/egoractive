import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_member_summary.dart';
import '../domain/admin_member_summary_mapper.dart';

part 'admin_member_list_page_service.g.dart';

/// F7-2 — büyük salonlarda (bkz. `scripts/seed_load_test_data.ts`, 10.000
/// üye) F2-2 üye listesinin ilk render'ının 3 saniyenin altında kalması
/// için tek seferlik `.snapshots()` yerine `orderBy('name')` + `limit` +
/// `startAfterDocument` ile sayfalı okuma.
const adminMemberListPageSize = 50;
const adminMemberListSearchLimit = 30;

class AdminMemberListPage {
  const AdminMemberListPage({required this.items, required this.lastDocument, required this.hasMore});

  final List<AdminMemberSummary> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

class AdminMemberListPageService {
  const AdminMemberListPageService();

  Future<AdminMemberListPage> loadPage(String gymId, {DocumentSnapshot<Map<String, dynamic>>? startAfter}) async {
    var query = _baseQuery(gymId).limit(adminMemberListPageSize);
    if (startAfter != null) query = query.startAfterDocument(startAfter);

    final snapshot = await query.get();
    return AdminMemberListPage(
      items: snapshot.docs.map(adminMemberSummaryFromDoc).toList(),
      lastDocument: snapshot.docs.isEmpty ? startAfter : snapshot.docs.last,
      hasMore: snapshot.docs.length == adminMemberListPageSize,
    );
  }

  /// Sunucu tarafında `name` alanı üzerinde prefix araması — pagination'a
  /// geçilince client-side "contains" araması artık sadece o an yüklü
  /// sayfalar üzerinde çalışabilirdi, bu yüzden arama ayrı bir sorgu.
  /// Kısıt: sadece isim başlangıcı eşleşir (telefon numarası ya da isim
  /// ortası araması bu sorguyla desteklenmiyor).
  Future<List<AdminMemberSummary>> searchByNamePrefix(String gymId, String prefix) async {
    final snapshot = await _baseQuery(gymId).startAt([prefix]).endAt(['$prefix']).limit(adminMemberListSearchLimit).get();
    return snapshot.docs.map(adminMemberSummaryFromDoc).toList();
  }

  Query<Map<String, dynamic>> _baseQuery(String gymId) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('gymId', isEqualTo: gymId)
        .where('role', isEqualTo: 'member')
        .orderBy('name');
  }
}

@riverpod
AdminMemberListPageService adminMemberListPageService(AdminMemberListPageServiceRef ref) => const AdminMemberListPageService();
