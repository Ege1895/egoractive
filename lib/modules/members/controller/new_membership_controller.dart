import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../packages/domain/studio_package.dart';
import '../domain/new_membership_state.dart';

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
      paidAmount: 0,
    );
  }

  void selectPackage(StudioPackage package) {
    state = state.copyWith(
      selectedPackage: package,
      endDate: state.startDate.add(Duration(days: package.validityDays)),
    );
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

  void setPaidFull() => state = state.copyWith(paidAmount: state.totalAmount);

  void setPaidHalf() =>
      state = state.copyWith(paidAmount: (state.totalAmount / 2).round());

  void setPaidAmount(int amount) =>
      state = state.copyWith(paidAmount: amount.clamp(0, state.totalAmount));

  void reset() => state = build();

  /// F3-2 — seçilen paket + ödeme bilgisiyle `memberPackages` dokümanını
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
          errorMessage: 'Aktif bir salon bulunamadı.',
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
        'totalAmount': state.totalAmount,
        'paidAmount': state.paidAmount,
        'dueAmount': state.dueAmount,
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
              'paid_amount': state.paidAmount,
            },
          );

      state = state.copyWith(isSaving: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errorMessage:
            'Ödeme kaydedilemedi, bağlantını kontrol edip tekrar dene.',
      );
      return false;
    }
  }
}
