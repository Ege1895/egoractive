import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/admin_member_summary.dart';
import '../domain/admin_member_summary_mapper.dart';
import '../repository/admin_members_repository.dart';

part 'admin_members_controller.g.dart';

/// `gyms/{gymId}` bilinmediği (henüz gerçek bir salon yoksa) çağrılmaz —
/// bu durumda [AdminMembersController] mock listeye düşer.
///
/// F7-2 — bilerek SINIRSIZ: üye detayı/seans-antrenör seçici/bildirim
/// hedefi gibi tüketiciler tüm üye kümesi üzerinde arama/seçim yapabilmeli.
/// Ana liste ekranı (F2-2, `AdminMemberListPanel`) büyük salon ölçeğinde
/// bunun yerine sayfalı [AdminMemberListController]'ı kullanıyor — bu
/// provider sadece o üç tüketici için hâlâ geçerli.
@riverpod
Stream<List<AdminMemberSummary>> _membersForGym(_MembersForGymRef ref, String gymId) {
  final endingSoonThreshold = ref
      .watch(remoteConfigServiceProvider)
      .memberEndingSoonSessionsThreshold;
  return FirebaseFirestore.instance
      .collection('users')
      .where('gymId', isEqualTo: gymId)
      .where('role', isEqualTo: 'member')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => adminMemberSummaryFromDoc(
                doc,
                endingSoonThreshold: endingSoonThreshold,
              ),
            )
            .toList(),
      );
}

/// Üye detayı/seans oluşturma/bildirim gönderme ekranlarının kullandığı,
/// aktif salonun üyelerini gerçek zamanlı listeleyen kontrolcü. Dış arayüz
/// bilerek senkron (`List<AdminMemberSummary>`) tutuldu — tüketiciler
/// `AsyncValue` bilmek zorunda değil; Firestore akışı burada sarmalanıyor.
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
