import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../domain/create_group_session_form.dart';
import '../repository/create_group_session_repository.dart';
import '../service/group_sessions_write_service.dart';

part 'create_group_session_controller.g.dart';

@riverpod
class CreateGroupSessionController extends _$CreateGroupSessionController {
  @override
  CreateGroupSessionForm build() =>
      ref.watch(createGroupSessionRepositoryProvider).loadInitial();

  void setTitle(String title) =>
      state = state.copyWith(title: title, titleError: null);

  void setStudioName(String studioName) =>
      state = state.copyWith(studioName: studioName);

  void toggleDay(int day) {
    final days = {...state.selectedDays};
    days.contains(day) ? days.remove(day) : days.add(day);
    state = state.copyWith(selectedDays: days, daysError: null);
  }

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

  /// Seçili her gün için o günün en yakın gelecekteki tekrarında bir
  /// `groupSessions` dokümanı oluşturur — tam bir tekrarlı seri motoru
  /// değil (F4-2 kapsamı bunu gerektirmiyor), her seçili gün için tek bir
  /// gerçek, katılınabilir seans. Boş başlıkta veya gün seçilmemişse
  /// alanların altına spesifik hata yazıp `false` döner — önceki sürüm
  /// sessizce hiçbir açıklama vermeden `false` dönüyordu.
  Future<bool> submit() async {
    final title = state.title.trim();
    final titleError = title.isEmpty ? 'Ders adı boş bırakılamaz.' : null;
    final daysError = state.selectedDays.isEmpty ? 'En az bir gün seç.' : null;
    if (titleError != null || daysError != null) {
      state = state.copyWith(titleError: titleError, daysError: daysError);
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

      final timeParts = state.startTime.split(':');
      final hour = int.tryParse(timeParts.elementAt(0)) ?? 0;
      final minute = timeParts.length > 1
          ? int.tryParse(timeParts.elementAt(1)) ?? 0
          : 0;

      final service = ref.read(groupSessionsWriteServiceProvider);
      for (final weekday in state.selectedDays) {
        await service.createGroupSession(
          gymId: gymId,
          title: title,
          trainerName: trainerName?.isNotEmpty == true
              ? trainerName!
              : 'Antrenör',
          studioName: state.studioName,
          startTime: _nextOccurrence(weekday, hour, minute),
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

  DateTime _nextOccurrence(int weekday, int hour, int minute) {
    final now = DateTime.now();
    var date = DateTime(now.year, now.month, now.day, hour, minute);
    while (date.weekday != weekday || date.isBefore(now)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
}
