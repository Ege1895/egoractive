import 'package:freezed_annotation/freezed_annotation.dart';

import '../../packages/domain/studio_package.dart';

part 'new_membership_state.freezed.dart';

@freezed
class NewMembershipState with _$NewMembershipState {
  const factory NewMembershipState({
    StudioPackage? selectedPackage,
    required DateTime startDate,
    required DateTime endDate,
    required int makeupSessions,
    required int paidAmount,
    String? otherAmountDraft,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _NewMembershipState;

  const NewMembershipState._();

  int get totalAmount => selectedPackage?.priceTl ?? 0;

  int get dueAmount => (totalAmount - paidAmount).clamp(0, totalAmount);

  bool get isFullyPaid => dueAmount == 0 && totalAmount > 0;
}
