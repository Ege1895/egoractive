import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/remote_config/remote_config_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
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
    try {
      capacityMax = ref
          .watch(remoteConfigServiceProvider)
          .groupSessionCapacityMax;
    } catch (_) {
      capacityMax = initial.capacityMax;
    }
    return initial.copyWith(
      capacityMax: capacityMax,
      capacity: initial.capacity > capacityMax ? capacityMax : initial.capacity,
    );
  }

  void setTitle(String title) =>
      state = state.copyWith(title: title, titleError: null);

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
        .map(
          (date) =>
              DateTime(date.year, date.month, date.day, hour, minute),
        )
        .toList();
    if (!allowPast && startTimes.any((t) => t.isBefore(DateTime.now()))) {
      state = state.copyWith(
        dateError: 'Geçmiş bir tarih/saat seçilemez.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final gymId = await ref.read(activeGymIdProvider.future);
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (gymId == null || uid == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Aktif bir salon bulunamadı.',
        );
        return false;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final trainerName = (userDoc.data()?['name'] as String?)?.trim();

      final service = ref.read(groupSessionsWriteServiceProvider);
      for (final startTime in startTimes) {
        await service.createGroupSession(
          gymId: gymId,
          title: title,
          trainerName: trainerName?.isNotEmpty == true
              ? trainerName!
              : 'Antrenör',
          studioName: state.studioName,
          startTime: startTime,
          durationMinutes: state.durationMinutes,
          capacity: state.capacity,
          onlineBookingEnabled: state.onlineBookingEnabled,
        );
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Grup dersi oluşturulamadı, tekrar dene.',
      );
      return false;
    }
  }
}
