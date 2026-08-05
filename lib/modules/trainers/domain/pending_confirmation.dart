import 'package:freezed_annotation/freezed_annotation.dart';

part 'pending_confirmation.freezed.dart';

@freezed
class PendingConfirmation with _$PendingConfirmation {
  const factory PendingConfirmation({
    required String id,
    required String memberId,
    required String memberInitials,
    required String memberName,
    required String meta,
    required String time,
    required int remainingBefore,
  }) = _PendingConfirmation;
}
