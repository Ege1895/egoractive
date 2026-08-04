import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../packages/domain/studio_package.dart';
import '../domain/new_membership_state.dart';

part 'new_membership_controller.g.dart';

/// Yeni üyelik akışının (P4-6 → P4-7) paket + ödeme state'i — geri tuşuyla
/// paket adımına dönüldüğünde ödeme girişleri kaybolmasın diye tek state.
@riverpod
class NewMembershipController extends _$NewMembershipController {
  @override
  NewMembershipState build() {
    final now = DateTime(2026, 8, 3);
    return NewMembershipState(startDate: now, endDate: now, makeupSessions: 0, paidAmount: 0);
  }

  void selectPackage(StudioPackage package) {
    state = state.copyWith(
      selectedPackage: package,
      endDate: state.startDate.add(Duration(days: package.validityDays)),
    );
  }

  void incrementMakeup() => state = state.copyWith(makeupSessions: state.makeupSessions + 1);

  void decrementMakeup() {
    if (state.makeupSessions <= 0) return;
    state = state.copyWith(makeupSessions: state.makeupSessions - 1);
  }

  void setPaidFull() => state = state.copyWith(paidAmount: state.totalAmount);

  void setPaidHalf() => state = state.copyWith(paidAmount: (state.totalAmount / 2).round());

  void setPaidAmount(int amount) => state = state.copyWith(paidAmount: amount.clamp(0, state.totalAmount));

  void reset() => state = build();
}
