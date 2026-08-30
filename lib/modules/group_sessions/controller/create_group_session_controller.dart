import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../trainers/controller/admin_trainers_controller.dart';
import '../domain/create_group_session_form.dart';
import '../repository/create_group_session_repository.dart';
import '../service/group_sessions_write_service.dart';

part 'create_group_session_controller.g.dart';

@riverpod
class CreateGroupSessionController extends _$CreateGroupSessionController {
  @override
  CreateGroupSessionForm build() {
    final initial = ref
        .watch(createGroupSessionRepositoryProvider)
        .loadInitial();
    // RC henüz Firebase ile fetch edilmemişse (ör. Firebase.initializeApp
    // hiç çağrılmamış bir widget test ortamı) getInt çağrısı fırlatabilir —
    // bu durumda mock servisteki sabit üst sınırla devam edilir.
    int capacityMax;
    int descriptionMaxChars;
    try {
      final rc = ref.watch(remoteConfigServiceProvider);
      capacityMax = rc.groupSessionCapacityMax;
      descriptionMaxChars = rc.groupSessionDescriptionMaxChars;
    } catch (_) {
      capacityMax = initial.capacityMax;
      descriptionMaxChars = initial.descriptionMaxChars;
    }
    return initial.copyWith(
      capacityMax: capacityMax,
      capacity: initial.capacity > capacityMax ? capacityMax : initial.capacity,
      descriptionMaxChars: descriptionMaxChars,
    );
  }

  /// [CreateGroupSessionPanel] "yeni oluştur" modunda her açıldığında
  /// çağırır — `build()`'ün taze bir instance'ta yaptığı ilk yüklemeyi
  /// tekrarlar, önceki bir düzenleme/oluşturma denemesinden kalan state
  /// (editingId dahil) sızmasın diye (bkz. `GymSetupPanel.reset()` ile aynı
  /// desen).
  void resetForCreate() => state = build();

  /// [CreateGroupSessionPanel] düzenleme modunda açıldığında çağırır —
  /// mevcut dokümanı okuyup formu doldurur. "Tekrarla" burada anlamsız
  /// (tek bir mevcut doküman düzenleniyor), o yüzden `repeatDates`
  /// dokunulmadan boş kalır.
  Future<void> loadForEdit(String groupSessionId) async {
    state = state.copyWith(isLoadingForEdit: true, errorMessage: null);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('groupSessions')
          .doc(groupSessionId)
          .get();
      final data = doc.data();
      if (data == null) {
        state = state.copyWith(
          isLoadingForEdit: false,
          errorMessage: 'Ders bulunamadı.',
        );
        return;
      }
      final startTime = (data['startTime'] as Timestamp).toDate();
      state = state.copyWith(
        editingId: groupSessionId,
        title: (data['title'] as String?) ?? '',
        description: (data['description'] as String?) ?? '',
        trainerIds:
            (data['trainerIds'] as List?)?.whereType<String>().toList() ??
            const [],
        studioName: (data['studioName'] as String?) ?? '',
        selectedDate: DateTime(startTime.year, startTime.month, startTime.day),
        startTime:
            '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        durationMinutes:
            (data['durationMinutes'] as num?)?.toInt() ?? state.durationMinutes,
        capacity: (data['capacity'] as num?)?.toInt() ?? state.capacity,
        onlineBookingEnabled: (data['onlineBookingEnabled'] as bool?) ?? true,
        isLoadingForEdit: false,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingForEdit: false,
        errorMessage: 'Ders yüklenemedi, tekrar dene.',
      );
    }
  }

  void setTitle(String title) =>
      state = state.copyWith(title: title, titleError: null);

  void setDescription(String description) =>
      state = state.copyWith(description: description);

  bool get isDescriptionOverLimit =>
      state.description.length > state.descriptionMaxChars;

  void setTrainerIds(List<String> trainerIds) =>
      state = state.copyWith(trainerIds: trainerIds);

  void setStudioName(String studioName) =>
      state = state.copyWith(studioName: studioName);

  void setStartTime(String startTime) =>
      state = state.copyWith(startTime: startTime);

  void setDurationMinutes(int durationMinutes) =>
      state = state.copyWith(durationMinutes: durationMinutes);

  /// Ana tarih değişince önceki "Tekrarla" seçimi de sıfırlanır —
  /// `create_session_sheet.dart`'taki aynı davranış: eski seçim yeni ana
  /// tarihle bağlamını yitiriyor.
  void setSelectedDate(DateTime date) => state = state.copyWith(
    selectedDate: date,
    repeatDates: const [],
    dateError: null,
  );

  void setRepeatDates(List<DateTime> dates) =>
      state = state.copyWith(repeatDates: dates);

  void incrementCapacity() {
    if (state.capacity >= state.capacityMax) return;
    state = state.copyWith(capacity: state.capacity + 1);
  }

  void decrementCapacity() {
    if (state.capacity <= 1) return;
    state = state.copyWith(capacity: state.capacity - 1);
  }

  void toggleOnlineBooking() =>
      state = state.copyWith(onlineBookingEnabled: !state.onlineBookingEnabled);

  /// Ana tarih + "Tekrarla" ile seçilen ek tarihlerin HER biri için ayrı
  /// bir `groupSessions` dokümanı oluşturur (üyelerin grup dersi listesinde
  /// tek tek görünürler) — seanslardaki gibi bir üst sınır yok, admin
  /// istediği kadar tarih ekleyebilir. Boş başlıkta veya tarih
  /// seçilmemişse alanların altına spesifik hata yazıp `false` döner.
  Future<bool> submit() async {
    final title = state.title.trim();
    final titleError = title.isEmpty ? 'Ders adı boş bırakılamaz.' : null;
    final selectedDate = state.selectedDate;
    final dateError = selectedDate == null ? 'Tarih seçmelisin.' : null;
    if (titleError != null || dateError != null) {
      state = state.copyWith(titleError: titleError, dateError: dateError);
      return false;
    }
    // Buton zaten UI'da devre dışı bırakılıyor (bkz.
    // `create_group_session_panel.dart`) — burası ikinci bir savunma satırı.
    if (isDescriptionOverLimit) return false;

    final timeParts = state.startTime.split(':');
    final hour = int.tryParse(timeParts.elementAt(0)) ?? 0;
    final minute = timeParts.length > 1
        ? int.tryParse(timeParts.elementAt(1)) ?? 0
        : 0;
    final allowPast = ref
        .read(remoteConfigServiceProvider)
        .allowPastDatetimeCreation;
    final allDates = [selectedDate!, ...state.repeatDates];
    final startTimes = allDates
        .map((date) => DateTime(date.year, date.month, date.day, hour, minute))
        .toList();
    if (!allowPast && startTimes.any((t) => t.isBefore(DateTime.now()))) {
      state = state.copyWith(dateError: 'Geçmiş bir tarih/saat seçilemez.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final gymId = await ref.read(activeGymIdProvider.future);
      if (gymId == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Aktif bir salon bulunamadı.',
        );
        return false;
      }

      // Atanan antrenör(ler) opsiyonel — admin hiç seçmediyse boş liste
      // gönderilir, grup dersi yine oluşturulur.
      final allTrainers = ref.read(adminTrainersControllerProvider);
      final selectedTrainers = allTrainers
          .where((t) => state.trainerIds.contains(t.id))
          .toList(growable: false);

      final service = ref.read(groupSessionsWriteServiceProvider);
      final editingId = state.editingId;
      if (editingId != null) {
        // Düzenleme modu — "Tekrarla" geçerli değil, tek doküman güncellenir.
        await service.updateGroupSession(
          groupSessionId: editingId,
          title: title,
          description: state.description.trim(),
          trainerIds: selectedTrainers.map((t) => t.id).toList(),
          trainerNames: selectedTrainers.map((t) => t.name).toList(),
          studioName: state.studioName,
          startTime: startTimes.first,
          durationMinutes: state.durationMinutes,
          capacity: state.capacity,
          onlineBookingEnabled: state.onlineBookingEnabled,
        );
      } else {
        for (final startTime in startTimes) {
          await service.createGroupSession(
            gymId: gymId,
            title: title,
            description: state.description.trim(),
            trainerIds: selectedTrainers.map((t) => t.id).toList(),
            trainerNames: selectedTrainers.map((t) => t.name).toList(),
            studioName: state.studioName,
            startTime: startTime,
            durationMinutes: state.durationMinutes,
            capacity: state.capacity,
            onlineBookingEnabled: state.onlineBookingEnabled,
          );
        }
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: state.editingId != null
            ? 'Ders güncellenemedi, tekrar dene.'
            : 'Grup dersi oluşturulamadı, tekrar dene.',
      );
      return false;
    }
  }

  /// Ders listeden kaldırılmaz, iptal durumuyla işaretlenir (bkz.
  /// `GroupSessionsWriteService.cancelGroupSession`). Sadece düzenleme
  /// modunda (bir [editingId] varken) anlamlı.
  Future<bool> cancel() async {
    final editingId = state.editingId;
    if (editingId == null) return false;
    state = state.copyWith(isCancelling: true, errorMessage: null);
    try {
      await ref
          .read(groupSessionsWriteServiceProvider)
          .cancelGroupSession(editingId);
      state = state.copyWith(isCancelling: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isCancelling: false,
        errorMessage: 'İptal edilemedi, tekrar dene.',
      );
      return false;
    }
  }
}
