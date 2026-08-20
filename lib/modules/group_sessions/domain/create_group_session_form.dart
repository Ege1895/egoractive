import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_group_session_form.freezed.dart';

@freezed
class CreateGroupSessionForm with _$CreateGroupSessionForm {
  const factory CreateGroupSessionForm({
    required String title,
    required String startTime,
    required int durationMinutes,
    required Set<int> selectedDays,
    required int capacity,
    required int capacityMax,
    required bool onlineBookingEnabled,
    required String studioName,
    @Default(false) bool isSubmitting,
    String? titleError,
    String? daysError,
    String? errorMessage,
  }) = _CreateGroupSessionForm;
}
