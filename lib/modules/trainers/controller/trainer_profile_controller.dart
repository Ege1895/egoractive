import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';

part 'trainer_profile_controller.g.dart';

@riverpod
Stream<Map<String, dynamic>?> _trainerProfileDocForUid(
  _TrainerProfileDocForUidRef ref,
  String uid,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((doc) => doc.data());
}

/// [TrainerProfilePanel]'in üst kartındaki gerçek antrenör adı/uzmanlığı —
/// önceden `TrainerMockData`'dan sabit ("Berk Aydın") değer geliyordu,
/// giriş yapan antrenör ne olursa olsun aynı isim gösteriliyordu.
@riverpod
class TrainerProfileController extends _$TrainerProfileController {
  @override
  ({
    String name,
    String initials,
    String specialty,
    String phoneDigits,
    String email,
  })
  build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) {
      return (
        name: '',
        initials: '?',
        specialty: '',
        phoneDigits: '',
        email: '',
      );
    }

    final data = ref.watch(_trainerProfileDocForUidProvider(uid)).valueOrNull;
    final name = (data?['name'] as String?) ?? '';
    final specialties =
        (data?['specialties'] as List?)?.whereType<String>().toList() ??
        const [];
    return (
      name: name,
      initials: _initialsFor(name),
      specialty: specialties.isEmpty ? '' : specialties.first,
      phoneDigits: _digitsOnly((data?['phoneNumber'] as String?) ?? ''),
      email: (data?['email'] as String?) ?? '',
    );
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

  String _initialsFor(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}
