import 'package:cloud_firestore/cloud_firestore.dart';

import '../../trainers/domain/trainer_member_detail.dart';
import '../../trainers/domain/trainer_metric.dart';
import 'admin_member_detail.dart';

const _emptySeriesByMetric = {
  TrainerMetric.kilo: TrainerMetricSeries(
    metric: TrainerMetric.kilo,
    values: [],
    months: [],
  ),
  TrainerMetric.belCevresi: TrainerMetricSeries(
    metric: TrainerMetric.belCevresi,
    values: [],
    months: [],
  ),
  TrainerMetric.yagOrani: TrainerMetricSeries(
    metric: TrainerMetric.yagOrani,
    values: [],
    months: [],
  ),
};

/// `users/{memberId}` dokümanını [AdminMemberDetail]'e çevirir. Ödeme
/// bilgisi, ders geçmişi ve kilo/bel çevresi/yağ oranı serileri
/// [AdminMemberDetailController] tarafından ayrıca gerçek
/// `memberPackages`/`sessions`/`measurements` koleksiyonlarından
/// doldurulur — burada sadece ilk render'a kadar boş bırakılıyor.
AdminMemberDetail adminMemberDetailFromDoc(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data() ?? const {};
  final name = (data['name'] as String?)?.trim() ?? '';
  // "Kalan ders" — bkz. admin_member_summary_mapper.dart: henüz
  // planlanmamış hak + hâlâ takvimde bekleyen (tamamlanmamış) seans sayısı.
  final unplanned = (data['remainingSessions'] as num?)?.toInt() ?? 0;
  final planned = (data['plannedSessionsCount'] as num?)?.toInt() ?? 0;
  final remainingSessions = unplanned + planned;
  final packageEndDateIso = data['packageEndDate'] as String?;
  final packageEndDate = packageEndDateIso == null
      ? null
      : DateTime.tryParse(packageEndDateIso);
  return AdminMemberDetail(
    id: doc.id,
    initials: _initialsFor(name),
    name: name,
    phone: (data['phoneNumber'] as String?) ?? '',
    trainerName: (data['trainerName'] as String?) ?? '',
    remainingSessions: remainingSessions,
    makeupSessions: 0,
    packageEndDate: packageEndDate == null
        ? '—'
        : '${packageEndDate.day}.${packageEndDate.month}.${packageEndDate.year}',
    paymentTotalTl: 0,
    paymentPaidTl: 0,
    lastPaymentDate: '—',
    history: const [],
    seriesByMetric: _emptySeriesByMetric,
  );
}

/// Doküman henüz yüklenmemişken ([AdminMemberDetailController.build] ilk
/// çağrıldığında) gösterilecek geçici state — `notFound` ile karışmasın diye
/// ayrı bir bayrak.
AdminMemberDetail adminMemberDetailLoadingPlaceholder(String memberId) {
  return AdminMemberDetail(
    id: memberId,
    initials: '',
    name: '',
    phone: '',
    trainerName: '',
    remainingSessions: 0,
    makeupSessions: 0,
    packageEndDate: '—',
    paymentTotalTl: 0,
    paymentPaidTl: 0,
    lastPaymentDate: '—',
    history: const [],
    seriesByMetric: _emptySeriesByMetric,
    isLoading: true,
  );
}

/// `users/{memberId}` dokümanı silinmiş/hiç var olmamışsa gösterilecek
/// state — önceden burada crash oluyordu (`firstWhere` orElse'siz).
AdminMemberDetail adminMemberDetailNotFoundPlaceholder(String memberId) {
  return adminMemberDetailLoadingPlaceholder(
    memberId,
  ).copyWith(isLoading: false, notFound: true);
}

String _initialsFor(String name) {
  final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  final first = parts.first[0];
  final last = parts.length > 1 ? parts.last[0] : '';
  return '$first$last'.toUpperCase();
}
