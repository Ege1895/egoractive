import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_group_session_form.freezed.dart';

@freezed
class CreateGroupSessionForm with _$CreateGroupSessionForm {
  const factory CreateGroupSessionForm({
    required String title,
    required String startTime,
    required int durationMinutes,
    DateTime? selectedDate,

    /// "Tekrarla" ile seçilen EK tarihler — [selectedDate] hariç, her biri
    /// için ayrı bir `groupSessions` dokümanı oluşturulur. Seanslardan
    /// farklı olarak burada bir üst sınır yok (bkz.
    /// `create_group_session_controller.dart`).
    @Default(<DateTime>[]) List<DateTime> repeatDates,
    required int capacity,
    required int capacityMax,
    required bool onlineBookingEnabled,
    required String studioName,
    @Default(false) bool isSubmitting,
    String? titleError,
    String? dateError,
    String? errorMessage,
  }) = _CreateGroupSessionForm;
}
