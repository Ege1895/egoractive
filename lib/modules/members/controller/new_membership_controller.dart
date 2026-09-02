import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../shared/domain/membership_installment.dart';
import '../../packages/domain/studio_package.dart';
import '../domain/new_membership_state.dart';
import '../../../core/remote_config/remote_config_service.dart';

part 'new_membership_controller.g.dart';

/// Yeni üyelik akışının (P4-6 → P4-7) paket + ödeme state'i — geri tuşuyla
/// paket adımına dönüldüğünde ödeme girişleri kaybolmasın diye tek state.
@riverpod
class NewMembershipController extends _$NewMembershipController {
  @override
  NewMembershipState build() {
    final now = DateTime.now();
    return NewMembershipState(
      startDate: now,
      endDate: now,
      makeupSessions: 0,
      totalAmountTl: 0,
      installments: const [],
    );
  }

  void selectPackage(StudioPackage package) {
    state = state.copyWith(
      selectedPackage: package,
      endDate: state.startDate.add(Duration(days: package.validityDays)),
    );
    _resplit(totalAmountTl: package.priceTl, count: 1);
  }

  void incrementMakeup() =>
      state = state.copyWith(makeupSessions: state.makeupSessions + 1);

  void decrementMakeup() {
    if (state.makeupSessions <= 0) return;
    state = state.copyWith(makeupSessions: state.makeupSessions - 1);
  }

  /// Sayı klavyesinden elle giriş — negatif değer formatter tarafından zaten
  /// engelleniyor, burada sadece savunma amaçlı 0'a clamp'lanıyor.
  void setMakeupSessions(int value) =>
      state = state.copyWith(makeupSessions: value < 0 ? 0 : value);

  void updateStartDate(DateTime date) =>
      state = state.copyWith(startDate: date);

  void updateEndDate(DateTime date) => state = state.copyWith(endDate: date);

  /// Toplam tutar elle değiştirildiğinde mevcut taksit sayısı korunarak
  /// yeniden eşit bölünür.
  void setTotalAmount(int amount) => _resplit(
    totalAmountTl: amount,
    count: state.installments.isEmpty ? 1 : state.installments.length,
  );

  /// Taksit sayısı değiştiğinde mevcut toplam tutar yeniden eşit bölünür.
  void setInstallmentCount(int count) =>
      _resplit(totalAmountTl: state.totalAmountTl, count: count);

  /// Tek bir taksitin tutarını/tarihini/ödendi durumunu değiştirir —
  /// diğer taksitlere dokunmaz. Tutar değiştiyse toplam, tüm taksitlerin
  /// yeni toplamına eşitlenir (admin taksitler üstünden hesabı kendi takip
  /// eder).
  void updateInstallment(
    int index, {
    int? amountTl,
    DateTime? dueDate,
    bool? paid,
  }) {
    final updated = [
      for (final installment in state.installments)
        if (installment.index == index)
          installment.copyWith(
            amountTl: amountTl ?? installment.amountTl,
            dueDate: dueDate ?? installment.dueDate,
            paid: paid ?? installment.paid,
          )
        else
          installment,
    ];
    state = state.copyWith(
      installments: updated,
      totalAmountTl: updated.fold(0, (total, i) => total + i.amountTl),
    );
  }

  void _resplit({required int totalAmountTl, required int count}) {
    state = state.copyWith(
      totalAmountTl: totalAmountTl,
      installments: splitIntoInstallments(
        totalAmountTl: totalAmountTl,
        count: count,
        firstDueDate: state.startDate,
      ),
    );
  }

  void reset() => state = build();

  /// F3-2 — seçilen paket + taksit planıyla `memberPackages` dokümanını
  /// oluşturur ve üyenin liste görünümünde okunan `remainingSessions`/
  /// `packageEndDate` alanlarını `users/{memberId}` üzerinde günceller
  /// (admin üye listesi ek bir sorgu yapmasın diye denormalize edilir).
  /// Başarılıysa `true` döner. Önceki sürüm hiçbir hatayı yakalamıyordu —
  /// yazma başarısız olursa "Kaydet" butonu hiçbir şey olmamış gibi
  /// görünüyor, üyelik de oluşmuyordu.
  Future<bool> save(String memberId) async {
    final package = state.selectedPackage;
    if (package == null || state.isSaving) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      final gymId = await ref.read(activeGymIdProvider.future);
      if (gymId == null) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: ref.read(
            rcTextProvider(RemoteConfigKeys.commonNoActiveGymError),
          ),
        );
        return false;
      }

      final firestore = FirebaseFirestore.instance;
      await firestore.collection('memberPackages').add({
        'memberId': memberId,
        'gymId': gymId,
        'packageId': package.id,
        'packageName': package.name,
        'sessionType': package.sessionType.name,
        'totalSessions': package.sessionCount,
        'remainingSessions': package.sessionCount,
        'makeupSessions': state.makeupSessions,
        'startDate': state.startDate.toIso8601String(),
        'endDate': state.endDate.toIso8601String(),
        'totalAmount': state.totalAmountTl,
        'paidAmount': state.paidAmountTl,
        'dueAmount': state.dueAmountTl,
        'installments': state.installments.map(installmentToMap).toList(),
        // F5-1/F5-2/F5-3'teki ciro aggregation'ları (memberPackages.paidAmount
        // sum()) bu alana göre ay/hafta aralığı filtreliyor.
        'purchasedAt': FieldValue.serverTimestamp(),
      });

      await firestore.collection('users').doc(memberId).update({
        'remainingSessions': package.sessionCount,
        'packageEndDate': state.endDate.toIso8601String(),
        'packageName': package.name,
      });

      await ref
          .read(analyticsServiceProvider)
          .logEvent(
            AnalyticsEvent.packagePurchased,
            parameters: {
              'package_id': package.id,
              'gym_id': gymId,
              'paid_amount': state.paidAmountTl,
            },
          );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: ref.read(
          rcTextProvider(RemoteConfigKeys.membersPaymentSaveError),
        ),
      );
      return false;
    }
  }
}
