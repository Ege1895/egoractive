import 'package:cloud_firestore/cloud_firestore.dart';

import 'trainer_member_detail.dart';
import 'trainer_metric.dart';

const _months = ['Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu'];

/// `users/{memberId}` dokümanını [TrainerMemberDetail]'e çevirir. Ders
/// geçmişi/ölçüm serisi ve üyelik başlangıç tarihi henüz gerçek bir
/// Firestore koleksiyonuna bağlı değil (ayrı bir kapsam) — sabit placeholder
/// değerlerle dolduruluyor, sadece kimlik/kalan ders/paket bitiş alanları
/// gerçek dokümandan geliyor.
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
    history: const [
      SessionHistoryEntry(
        date: '30 Tem',
        type: 'Birebir · 18:30',
        stateLabel: 'Tamamlandı',
        isPositive: true,
      ),
      SessionHistoryEntry(
        date: '27 Tem',
        type: 'Birebir · 18:30',
        stateLabel: 'Tamamlandı',
        isPositive: true,
      ),
      SessionHistoryEntry(
        date: '23 Tem',
        type: 'Birebir · 18:30',
        stateLabel: 'İptal',
        isPositive: false,
      ),
      SessionHistoryEntry(
        date: '20 Tem',
        type: 'Birebir · 18:30',
        stateLabel: 'Tamamlandı',
        isPositive: true,
      ),
    ],
    seriesByMetric: const {
      TrainerMetric.kilo: TrainerMetricSeries(
        metric: TrainerMetric.kilo,
        values: [68.4, 67.8, 67.1, 66.5, 65.9, 65.2],
        months: _months,
      ),
      TrainerMetric.belCevresi: TrainerMetricSeries(
        metric: TrainerMetric.belCevresi,
        values: [82, 81, 80, 79.2, 78.5, 77.6],
        months: _months,
      ),
      TrainerMetric.yagOrani: TrainerMetricSeries(
        metric: TrainerMetric.yagOrani,
        values: [27.5, 26.8, 26.1, 25.4, 24.9, 24.1],
        months: _months,
      ),
    },
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
    seriesByMetric: const {
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
    },
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
