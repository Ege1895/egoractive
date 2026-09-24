import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../domain/trainer_member_summary.dart';
import '../repository/trainer_members_repository.dart';

part 'trainer_members_controller.g.dart';

/// F2-3 — sadece bu antrenöre (`trainerId == uid`) atanmış üyeleri gerçek
/// zamanlı dinler. Security Rules ile de garanti altına alınacak (F2-6) —
/// bu sorgu client tarafı ilk savunma hattı.
@riverpod
Stream<List<TrainerMemberSummary>> _membersForTrainer(
  _MembersForTrainerRef ref,
  String trainerUid,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'member')
      .where('trainerId', isEqualTo: trainerUid)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(_toSummary).toList());
}

TrainerMemberSummary _toSummary(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  final name = (data['name'] as String?)?.trim() ?? '';
  final remainingSessions = (data['remainingSessions'] as num?)?.toInt() ?? 0;
  final packageName = (data['packageName'] as String?)?.trim() ?? '';
  return TrainerMemberSummary(
    id: doc.id,
    initials: _initialsFor(name),
    name: name,
    packageName: remainingSessions <= 0 || packageName.isEmpty
        ? 'Paketi yok'
        : packageName,
    remainingSessions: remainingSessions,
  );
}

String _initialsFor(String name) {
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}

/// Dış arayüz bilerek senkron (`List<TrainerMemberSummary>`) tutuldu — mevcut
/// panel `AsyncValue` bilmek zorunda değil. Oturum yoksa (uid bilinmiyorsa)
/// mock listeye düşer.
@riverpod
class TrainerMembersController extends _$TrainerMembersController {
  @override
  List<TrainerMemberSummary> build() {
    final authAsync = ref.watch(authStateProvider);
    // F13-6 — provider ilk izlendiğinde henüz sonuçlanmamış olabilir; bu
    // durum "gerçekten oturum yok" ile AYNI DEĞİL. O ana kadar mock'a
    // düşülürse kullanıcı bir an sahte veriyi gerçekmiş gibi görür ve
    // dokunduğunda var olmayan bir ID ile Firestore'a yazma denenir (bkz.
    // `discover_controller.dart`/`trainer_home_controller.dart` — aynı hata
    // orada yaşandı ve düzeltildi).
    if (authAsync.isLoading) return const [];
    final uid = authAsync.valueOrNull?.uid;
    if (uid == null) {
      return ref.watch(trainerMembersRepositoryProvider).loadMembers();
    }
    return ref.watch(_membersForTrainerProvider(uid)).valueOrNull ?? const [];
  }
}
