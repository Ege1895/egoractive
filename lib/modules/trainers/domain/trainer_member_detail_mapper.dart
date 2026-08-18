import 'package:cloud_firestore/cloud_firestore.dart';

import 'trainer_member_detail.dart';
import 'trainer_metric.dart';

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

/// `users/{memberId}` dokümanını [TrainerMemberDetail]'e çevirir. Ders
/// geçmişi ve bel çevresi serisi [TrainerMemberDetailController] tarafından
/// ayrıca gerçek `sessions`/`measurements` koleksiyonlarından doldurulur —
/// burada boş bırakılıyor. Kilo ve yağ oranı hiçbir yerde tutulmuyor
/// (ölçüm modülü sadece göğüs/kol/bel/kalça/bacak cm ölçer), bu yüzden
/// gerçek bir kaynağı olmayan bu iki metrik kalıcı olarak boş kalır —
/// önceden hepsi sabit uydurma sayılarla doluydu.
TrainerMemberDetail trainerMemberDetailFromDoc(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data() ?? const {};
  final name = (data['name'] as String?)?.trim() ?? '';
  final remainingSessions = (data['remainingSessions'] as num?)?.toInt() ?? 0;
  final packageEndDateIso = data['packageEndDate'] as String?;
  final packageEndDate = packageEndDateIso == null
      ? null
      : DateTime.tryParse(packageEndDateIso);
  return TrainerMemberDetail(
    id: doc.id,
    initials: _initialsFor(name),
    name: name,
    phone: (data['phoneNumber'] as String?) ?? '',
    memberSince: '—',
    remainingSessions: remainingSessions,
    packageEndDate: packageEndDate == null
        ? '—'
        : '${packageEndDate.day}.${packageEndDate.month}.${packageEndDate.year}',
    history: const [],
    seriesByMetric: _emptySeriesByMetric,
  );
}

TrainerMemberDetail trainerMemberDetailLoadingPlaceholder(String memberId) {
  return TrainerMemberDetail(
    id: memberId,
    initials: '',
    name: '',
    phone: '',
    memberSince: '—',
    remainingSessions: 0,
    packageEndDate: '—',
    history: const [],
    seriesByMetric: _emptySeriesByMetric,
    isLoading: true,
  );
}

/// `users/{memberId}` dokümanı bulunamazsa gösterilecek state — önceden
/// burada crash oluyordu (`firstWhere` orElse'siz).
TrainerMemberDetail trainerMemberDetailNotFoundPlaceholder(String memberId) {
  return trainerMemberDetailLoadingPlaceholder(
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
