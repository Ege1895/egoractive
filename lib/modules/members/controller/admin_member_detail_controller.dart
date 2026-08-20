import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/domain/membership_installment.dart';
import '../../trainers/domain/trainer_member_detail.dart';
import '../../trainers/domain/trainer_metric.dart';
import '../domain/admin_member_detail.dart';
import '../domain/admin_member_detail_mapper.dart';
import '../repository/admin_member_detail_repository.dart';
import '../service/membership_installment_write_service.dart';

part 'admin_member_detail_controller.g.dart';

const _monthAbbrev = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

@riverpod
Stream<AdminMemberDetail> _detailStreamForId(
  _DetailStreamForIdRef ref,
  String memberId,
) {
  return ref.watch(adminMemberDetailRepositoryProvider).watchDetail(memberId);
}

/// Üyenin en güncel `memberPackages` kaydı — ödeme durumu/telafi hakkı bu
/// dokümandan gerçek veriyle okunur (bkz. NewMembershipController.save).
@riverpod
Stream<QueryDocumentSnapshot<Map<String, dynamic>>?> _latestPackageForMember(
  _LatestPackageForMemberRef ref,
  String memberId,
) {
  return FirebaseFirestore.instance
      .collection('memberPackages')
      .where('memberId', isEqualTo: memberId)
      .orderBy('purchasedAt', descending: true)
      .limit(1)
      .snapshots()
      .map((snapshot) => snapshot.docs.isEmpty ? null : snapshot.docs.first);
}

/// Tek bir index gerektirmemek için sadece `memberId` eşitliğiyle
/// sorgulanır, durum filtresi client-side yapılır.
@riverpod
Stream<List<SessionHistoryEntry>> _sessionHistoryForAdminMember(
  _SessionHistoryForAdminMemberRef ref,
  String memberId,
) {
  return FirebaseFirestore.instance
      .collection('sessions')
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
            .map(_toHistoryEntry)
            .toList();
      });
}

SessionHistoryEntry _toHistoryEntry(
  QueryDocumentSnapshot<Map<String, dynamic>> doc,
) {
  final data = doc.data();
  final startTime = (data['startTime'] as Timestamp).toDate();
  final time =
      '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  final isCompleted = data['status'] == 'completed';
  return SessionHistoryEntry(
    date: '${startTime.day} ${_monthAbbrev[startTime.month] ?? ''}',
    type: 'Birebir · $time',
    stateLabel: isCompleted ? 'Tamamlandı' : 'İptal',
    isPositive: isCompleted,
  );
}

/// Ölçüm modülünün `measurements/{memberId}/entries` koleksiyonundaki
/// gerçek bel ölçüsü — "belCevresi" metriği için kullanılabilecek tek
/// gerçek kaynak (kilo ve yağ oranı hiçbir yerde tutulmuyor).
@riverpod
Stream<TrainerMetricSeries> _waistSeriesForAdminMember(
  _WaistSeriesForAdminMemberRef ref,
  String memberId,
) {
  return FirebaseFirestore.instance
      .collection('measurements')
      .doc(memberId)
      .collection('entries')
      .orderBy('date')
      .snapshots()
      .map((snapshot) {
        final months = <String>[];
        final values = <double>[];
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final bel = data['bel'];
          if (bel is num) {
            final date = (data['date'] as Timestamp).toDate();
            months.add(_monthAbbrev[date.month] ?? '');
            values.add(bel.toDouble());
          }
        }
        return TrainerMetricSeries(
          metric: TrainerMetric.belCevresi,
          values: values,
          months: months,
        );
      });
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
    final waistSeries = ref
        .watch(_waistSeriesForAdminMemberProvider(memberId))
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
          : '${purchasedAt.day} ${_monthAbbrev[purchasedAt.month] ?? ''}',
      history: history,
      seriesByMetric: waistSeries == null
          ? base.seriesByMetric
          : {...base.seriesByMetric, TrainerMetric.belCevresi: waistSeries},
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
