import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/theme/theme_controller.dart';
import '../../../shared/domain/membership_installment.dart';
import '../../trainers/domain/trainer_member_detail.dart';
import '../../trainers/domain/trainer_metric.dart';
import '../../trainers/domain/trainer_metric_measurement_source.dart';
import '../domain/admin_member_detail.dart';
import '../domain/admin_member_detail_mapper.dart';
import '../repository/admin_member_detail_repository.dart';
import '../service/membership_installment_write_service.dart';
import '../../../shared/utils/date_labels.dart';
import '../../../core/remote_config/remote_config_service.dart';

part 'admin_member_detail_controller.g.dart';

@riverpod
Stream<AdminMemberDetail> _detailStreamForId(
  _DetailStreamForIdRef ref,
  String memberId,
) {
  return ref.watch(adminMemberDetailRepositoryProvider).watchDetail(memberId);
}

/// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
/// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
///
/// `gymId` eşitliği bilerek eklendi: `firestore.rules`'taki
/// `memberPackages` okuma kuralı `resource.data.gymId == myGymId()`'e
/// bakıyor, ama bir LIST sorgusunda Firestore bu kuralı sorgunun KENDİSİ
/// üzerinden (dönen dokümanlar üzerinden değil) doğruluyor — sorguda
/// `gymId` filtresi olmadan kural `resource.data.gymId undefined` hatasıyla
/// TÜM sorguyu reddediyordu (admin SDK bu kuralları atladığı için bu bug
/// production'da fark edilmeden duruyordu). Aynı BUG `_sessionHistoryForAdminMember`
/// için de geçerliydi, orada da düzeltildi.
@riverpod
Stream<QueryDocumentSnapshot<Map<String, dynamic>>?> _latestPackageForMember(
  _LatestPackageForMemberRef ref,
  String memberId,
) {
  final gymId = ref.watch(activeGymIdProvider).valueOrNull;
  if (gymId == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('memberPackages')
      .where('gymId', isEqualTo: gymId)
      .where('memberId', isEqualTo: memberId)
      .orderBy('purchasedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) => snapshot.docs.isEmpty ? null : snapshot.docs.first);
}

/// `gymId` filtresi `_latestPackageForMember`'daki aynı sebeple eklendi —
/// `sessions` okuma kuralı da `resource.data.gymId == myGymId()` istiyor,
/// LIST sorgusunda bu filtre olmadan kural sorgunun tamamını reddediyordu.
@riverpod
Stream<List<SessionHistoryEntry>> _sessionHistoryForAdminMember(
  _SessionHistoryForAdminMemberRef ref,
  String memberId,
) {
  final gymId = ref.watch(activeGymIdProvider).valueOrNull;
  if (gymId == null) return Stream.value(const []);
  final labels = ref.watch(dateLabelsProvider);
  final texts = _HistoryLabels(
    soloWithTimeTemplate: ref.watch(
      rcTextProvider(RemoteConfigKeys.commonSoloSessionWithTimeTemplate),
    ),
    completed: ref.watch(rcTextProvider(RemoteConfigKeys.commonTamamlandi)),
    cancelled: ref.watch(rcTextProvider(RemoteConfigKeys.commonIptalLabel)),
  );
  return FirebaseFirestore.instance
      .collection('sessions')
      .where('gymId', isEqualTo: gymId)
      .where('memberId', isEqualTo: memberId)
      .orderBy('startTime', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .where((doc) {
              final status = doc.data()['status'] as String?;
              return status == 'completed' || status == 'cancelled';
            })
            .take(10)
            .map((doc) => _toHistoryEntry(doc, labels, texts))
            .toList();
      });
}

SessionHistoryEntry _toHistoryEntry(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
  DateLabels labels,
  _HistoryLabels texts,
) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  final isCompleted = data['status'] == 'completed';
  return SessionHistoryEntry(
    date: labels.dayMonthShort(startTime),
    type: texts.soloWithTimeTemplate.replaceAll('{time}', time),
    stateLabel: isCompleted ? texts.completed : texts.cancelled,
    isPositive: isCompleted,
  );
}

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundan
/// admin'in üye detayındaki dropdown'ın 3 metriğinin (kilo/bel çevresi/
/// yağ oranı) tamamını tek sorgudan üretir (bkz.
/// `trainer_metric_measurement_source.dart` — antrenör tarafındaki
/// karşılığıyla aynı kaynak).
@riverpod
Stream<Map<TrainerMetric, TrainerMetricSeries>> _metricSeriesForAdminMember(
  _MetricSeriesForAdminMemberRef ref,
  String memberId,
) {
  return watchTrainerMetricSeries(memberId, ref.watch(dateLabelsProvider));
}

@riverpod
class AdminMemberDetailController extends _$AdminMemberDetailController {
  @override
  AdminMemberDetail build(String memberId) {
    final base =
        ref.watch(_detailStreamForIdProvider(memberId)).valueOrNull ??
        adminMemberDetailLoadingPlaceholder(memberId);
    if (base.isLoading || base.notFound) return base;

    final package = ref
        .watch(_latestPackageForMemberProvider(memberId))
        .valueOrNull;
    final history =
        ref
            .watch(_sessionHistoryForAdminMemberProvider(memberId))
            .valueOrNull ??
        base.history;
    final metricSeries = ref
        .watch(_metricSeriesForAdminMemberProvider(memberId))
        .valueOrNull;

    final packageData = package?.data();
    final purchasedAt = (packageData?['purchasedAt'] as Timestamp?)?.toDate();
    final installmentMaps =
        (packageData?['installments'] as List?)?.cast<Map<String, dynamic>>() ??
        const [];
    return base.copyWith(
      makeupSessions: (packageData?['makeupSessions'] as num?)?.toInt() ?? 0,
      paymentTotalTl: (packageData?['totalAmount'] as num?)?.toInt() ?? 0,
      paymentPaidTl: (packageData?['paidAmount'] as num?)?.toInt() ?? 0,
      lastPaymentDate: purchasedAt == null
          ? '—'
          : ref.watch(dateLabelsProvider).dayMonthShort(purchasedAt),
      history: history,
      seriesByMetric: metricSeries ?? base.seriesByMetric,
      packageDocId: package?.id,
      installments: installmentMaps.map(installmentFromMap).toList(),
    );
  }

  void selectMetric(TrainerMetric metric) =>
      state = state.copyWith(selectedMetric: metric);

  /// [AdminMemberDetailPanel]'deki "Ödeme durumu" kartında bir taksite
  /// dokunup düzenleme popup'ından "Kaydet"e basıldığında çağrılır.
  /// Firestore yazımından sonra `state` doğrudan güncellenir — sadece
  /// `_latestPackageForMemberProvider` stream'inin yeniden yayın yapmasına
  /// güvenmek, bu ekran başka bir panelden (ör. [EditMemberPaymentPanel])
  /// çağrıldığında geri dönülen panelin güncel veriyi göstermesi bir
  /// sonraki manuel yenilemeye kadar gecikebiliyordu.
  Future<void> updateInstallment(
    int index, {
    required int amountTl,
    required DateTime dueDate,
    required bool paid,
  }) async {
    final packageDocId = state.packageDocId;
    if (packageDocId == null) return;
    await ref
        .read(membershipInstallmentWriteServiceProvider)
        .updateInstallment(
          packageDocId: packageDocId,
          index: index,
          amountTl: amountTl,
          dueDate: dueDate,
          paid: paid,
        );
    final updatedInstallments = [
      for (final installment in state.installments)
        if (installment.index == index)
          installment.copyWith(amountTl: amountTl, dueDate: dueDate, paid: paid)
        else
          installment,
    ];
    state = state.copyWith(
      installments: updatedInstallments,
      paymentPaidTl: updatedInstallments
          .where((i) => i.paid)
          .fold(0, (total, i) => total + i.amountTl),
    );
  }

  /// [EditMemberPaymentPanel]'in "Kaydet" butonu — toplam tutarı ve tüm
  /// taksit planını değiştirir. `packageDocId` yoksa (üyenin hiç paketi
  /// yoksa) sessizce hiçbir şey yapmaz, çağıran taraf bu ekranı zaten o
  /// durumda açmamalı. Firestore yazımından hemen sonra `state` doğrudan
  /// güncellenir (bkz. [updateInstallment] üstündeki not) — geri dönülen
  /// `AdminMemberDetailPanel` stream'in yeniden yayın yapmasını beklemeden
  /// güncel veriyi gösterir.
  Future<void> saveInstallmentPlan({
    required int totalAmountTl,
    required List<MembershipInstallment> installments,
  }) async {
    final packageDocId = state.packageDocId;
    if (packageDocId == null) return;
    await ref
        .read(membershipInstallmentWriteServiceProvider)
        .setInstallmentPlan(
          packageDocId: packageDocId,
          totalAmountTl: totalAmountTl,
          installments: installments,
        );
    state = state.copyWith(
      installments: installments,
      paymentTotalTl: totalAmountTl,
      paymentPaidTl: installments
          .where((i) => i.paid)
          .fold(0, (total, i) => total + i.amountTl),
    );
  }
}

/// Seans geçmişi satırındaki sabit metinler — RC'den okunup buraya
/// taşınıyor (servis/mapper katmanı RC'ye erişmiyor).
class _HistoryLabels {
  const _HistoryLabels({
    required this.soloWithTimeTemplate,
    required this.completed,
    required this.cancelled,
  });

  final String soloWithTimeTemplate;
  final String completed;
  final String cancelled;
}
