import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/domain/membership_installment.dart';
import '../domain/member_package.dart';
import '../repository/package_repository.dart';
import '../../../shared/utils/date_labels.dart';

part 'package_controller.g.dart';

@riverpod
Stream<Map<String, dynamic>?> _memberDocForId(
  _MemberDocForIdRef ref,
  String memberId,
) {
  return ref.watch(packageRepositoryProvider).watchMemberDoc(memberId);
}

@riverpod
Stream<Map<String, dynamic>?> _latestPackageDocForId(
  _LatestPackageDocForIdRef ref,
  String memberId,
) {
  return ref.watch(packageRepositoryProvider).watchLatestPackageDoc(memberId);
}

@riverpod
Future<String> _trainerSpecialtyForId(
  _TrainerSpecialtyForIdRef ref,
  String trainerId,
) {
  return ref.watch(packageRepositoryProvider).loadTrainerSpecialty(trainerId);
}

/// Üye 4 · Paketim. Oturum yoksa (test ortamı vb.) boş bir paket gösterir.
@riverpod
class PackageController extends _$PackageController {
  @override
  MemberPackage build() {
    final uid = ref.watch(authStateProvider).valueOrNull?.uid;
    if (uid == null) return MemberPackage.empty;

    final memberData = ref.watch(_memberDocForIdProvider(uid)).valueOrNull;
    if (memberData == null) return MemberPackage.empty;
    final packageData = ref
        .watch(_latestPackageDocForIdProvider(uid))
        .valueOrNull;

    final trainerId = memberData['trainerId'] as String?;
    final trainerName = (memberData['trainerName'] as String?) ?? '—';
    final trainerSpecialty = trainerId == null
        ? ''
        : ref.watch(_trainerSpecialtyForIdProvider(trainerId)).valueOrNull ??
              '';

    final startDate = _dateFrom(packageData?['startDate'] as String?);
    final endDate = _dateFrom(
      (memberData['packageEndDate'] ?? packageData?['endDate']) as String?,
    );

    final installmentMaps =
        (packageData?['installments'] as List?)?.cast<Map<String, dynamic>>() ??
        const [];

    return MemberPackage(
      name: (packageData?['packageName'] as String?) ?? 'Aktif paket yok',
      remainingSessions:
          (memberData['remainingSessions'] as num?)?.toInt() ?? 0,
      totalSessions: (packageData?['totalSessions'] as num?)?.toInt() ?? 0,
      makeupSessions: (packageData?['makeupSessions'] as num?)?.toInt() ?? 0,
      startDate: startDate,
      endDate: endDate,
      trainerName: trainerName,
      trainerSpecialty: trainerSpecialty,
      trainerInitials: _initialsFor(trainerName),
      dueAmountTl: (packageData?['dueAmount'] as num?)?.toInt() ?? 0,
      installments: installmentMaps.map(installmentFromMap).toList(),
    );
  }

  String _dateFrom(String? iso) {
    if (iso == null) return '—';
    final date = DateTime.tryParse(iso);
    return date == null ? '—' : ref.read(dateLabelsProvider).dayMonthYear(date);
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
