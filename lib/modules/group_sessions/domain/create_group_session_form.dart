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
    @Default('') String description,

    /// RC'den (`groupSessionDescriptionMaxChars`, varsayılan 500) okunur —
    /// [description] bunu aşınca sayaç kırmızıya döner, "Grup dersi
    /// oluştur" butonu devre dışı kalır.
    @Default(500) int descriptionMaxChars,

    /// Atanan antrenör(ler) — opsiyonel, boş bırakılabilir. Çoklu seçime
    /// izin verir (bkz. `create_group_session_panel.dart`'taki antrenör
    /// seçim sheet'i).
    @Default(<String>[]) List<String> trainerIds,
    @Default(false) bool isSubmitting,
    String? titleError,
    String? dateError,
    String? errorMessage,

    /// Admin'in düzenleme ekranından (bkz. `create_group_session_panel.dart`)
    /// var olan bir dersi açtığını gösterir — dolu ise `submit()` "Tekrarla"
    /// olmadan TEK dokümanı günceller, boşsa (yeni oluşturma) mevcut
    /// davranış (ana tarih + tekrar tarihleri için ayrı ayrı oluşturma)
    /// aynen çalışır.
    String? editingId,
    @Default(false) bool isLoadingForEdit,
    @Default(false) bool isCancelling,
  }) = _CreateGroupSessionForm;
}
