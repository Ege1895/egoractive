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
@riverpod
class MemberProfileController extends _$MemberProfileController {
  @override
  ({String name, String phoneDigits}) build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return (name: '', phoneDigits: '');

    final data = ref.watch(_profileDocForUidProvider(uid)).valueOrNull;
    final name = (data?['name'] as String?) ?? '';
    final phoneDigits = _digitsOnly((data?['phoneNumber'] as String?) ?? '');
    return (name: name, phoneDigits: phoneDigits);
  }

  String _digitsOnly(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final withoutCountryCode = digits.startsWith('90') && digits.length > 10
        ? digits.substring(2)
        : digits;
    return withoutCountryCode.length > 10
        ? withoutCountryCode.substring(withoutCountryCode.length - 10)
        : withoutCountryCode;
  }
}
