import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';

part 'member_profile_controller.g.dart';

@riverpod
Stream<Map<String, dynamic>?> _profileDocForUid(
  _ProfileDocForUidRef ref,
  String uid,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data());
}

/// [ProfilePanel]'in üst kartındaki gerçek kullanıcı adı/telefonu —
/// önceden `MemberMockProfile`'dan sabit ("Ayşe Yılmaz") değer geliyordu,
/// giriş yapan kullanıcı ne olursa olsun aynı isim gösteriliyordu.
///
/// `sessionReminderEnabled` de burada tutuluyor — önceden `AuthController`'da
/// sadece bellekte tutulup hiçbir yere yazılmıyordu, oturum kapatılınca
/// sessizce varsayılana dönüyordu.
@riverpod
class MemberProfileController extends _$MemberProfileController {
  @override
  ({String name, String phoneE164, String email, bool sessionReminderEnabled})
  build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      return (name: '', phoneE164: '', email: '', sessionReminderEnabled: true);
    }

    final data = ref.watch(_profileDocForUidProvider(uid)).valueOrNull;
    final name = (data?['name'] as String?) ?? '';
    return (
      name: name,
      phoneE164: (data?['phoneNumber'] as String?) ?? '',
      email: (data?['email'] as String?) ?? '',
      sessionReminderEnabled:
          (data?['sessionReminderEnabled'] as bool?) ?? true,
    );
  }

  Future<void> toggleSessionReminder() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'sessionReminderEnabled': !state.sessionReminderEnabled,
    }, SetOptions(merge: true));
  }
}
