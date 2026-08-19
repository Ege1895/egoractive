import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/domain/membership_installment.dart';
import '../../packages/domain/studio_package.dart';

part 'new_membership_state.freezed.dart';

@freezed
class NewMembershipState with _$NewMembershipState {
  const factory NewMembershipState({
    StudioPackage? selectedPackage,
    required DateTime startDate,
    required DateTime endDate,
    required int makeupSessions,
    required int totalAmountTl,
    required List<MembershipInstallment> installments,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _NewMembershipState;

  const NewMembershipState._();

  int get paidAmountTl => installments
      .where((i) => i.paid)
      .fold(0, (total, i) => total + i.amountTl);

  int get dueAmountTl => (totalAmountTl - paidAmountTl).clamp(0, totalAmountTl);

  bool get isFullyPaid =>
      installments.isNotEmpty && installments.every((i) => i.paid);
}
