import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_feedback_entry.freezed.dart';

@freezed
class AdminFeedbackEntry with _$AdminFeedbackEntry {
  const factory AdminFeedbackEntry({
    required String id,
    required String initials,
    required String memberName,
    required String meta,
    required int stars,
    required String comment,
  }) = _AdminFeedbackEntry;
}

@freezed
class AdminFeedbackSummary with _$AdminFeedbackSummary {
  const factory AdminFeedbackSummary({
    required double average,
    required int totalCount,
    required Map<int, int> starCounts,
    required List<AdminFeedbackEntry> entries,
  }) = _AdminFeedbackSummary;
}
