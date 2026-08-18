import 'package:cloud_firestore/cloud_firestore.dart';

import '../../trainers/domain/trainer_member_detail.dart';
import '../../trainers/domain/trainer_metric.dart';
import 'admin_member_detail.dart';

const _months = ['Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu'];

/// `users/{memberId}` dokümanını [AdminMemberDetail]'e çevirir. Ödeme/ders
/// geçmişi/ölçüm serisi henüz gerçek bir Firestore koleksiyonuna bağlı değil
/// (ayrı bir kapsam) — bu yüzden sabit placeholder değerlerle dolduruluyor,
/// sadece kimlik/kalan ders/paket bitiş alanları gerçek dokümandan geliyor.
AdminMemberDetail adminMemberDetailFromDoc(
  DocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data() ?? const {};
  final name = (data['name'] as String?)?.trim() ?? '';
  final remainingSessions = (data['remainingSessions'] as num?)?.toInt() ?? 0;
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
    makeupSessions: 2,
    packageEndDate: packageEndDate == null
        ? '—'
        : '${packageEndDate.day}.${packageEndDate.month}.${packageEndDate.year}',
    paymentTotalTl: 14400,
    paymentPaidTl: 9600,
    lastPaymentDate: '8 Ağustos',
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
