import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/schedule_slot.dart';
import '../domain/trainer_calendar_state.dart';

part 'trainer_calendar_service.g.dart';

/// Mock servis — F3'te gerçek `sessions` koleksiyonundan aya göre çekecek.
class TrainerCalendarService {
  const TrainerCalendarService();

  TrainerCalendarState loadInitial() {
    return TrainerCalendarState(
      selectedDate: DateTime(2026, 8, 3),
      slotsByDayOfMonth: {
        3: const [
          ScheduleSlot(id: 'w-3-1', time: '09:00', name: 'Zeynep Kaya', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.completed),
          ScheduleSlot(id: 'w-3-2', time: '18:30', name: 'Ayşe Yılmaz', meta: 'Birebir · Stüdyo 2', state: ScheduleSlotState.planned),
        ],
        4: const [
          ScheduleSlot(id: 'w-4-1', time: '10:00', name: 'Reformer Grup', meta: '6/8 kişi · Stüdyo 1', state: ScheduleSlotState.planned),
        ],
        5: const [],
        6: const [
          ScheduleSlot(id: 'w-6-1', time: '09:00', name: 'Zeynep Kaya', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.planned),
          ScheduleSlot(id: 'w-6-2', time: '16:00', name: 'Cem Demir', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.planned),
        ],
        7: const [
          ScheduleSlot(id: 'w-7-1', time: '18:30', name: 'Ayşe Yılmaz', meta: 'Birebir · Stüdyo 2', state: ScheduleSlotState.planned),
        ],
        8: const [],
        9: const [
          ScheduleSlot(id: 'w-9-1', time: '11:00', name: 'Fonksiyonel Grup', meta: '5/12 kişi · Stüdyo 1', state: ScheduleSlotState.planned),
        ],
        12: const [
          ScheduleSlot(id: 'm-12-1', time: '10:00', name: 'Mert Arslan', meta: 'Birebir · Stüdyo 2', state: ScheduleSlotState.planned),
        ],
        18: const [
          ScheduleSlot(id: 'm-18-1', time: '09:00', name: 'Zeynep Kaya', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.planned),
          ScheduleSlot(id: 'm-18-2', time: '19:00', name: 'Cem Demir', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.planned),
        ],
        24: const [
          ScheduleSlot(id: 'm-24-1', time: '10:00', name: 'Reformer Grup', meta: '7/8 kişi · Stüdyo 1', state: ScheduleSlotState.planned),
        ],
      },
    );
  }
}

@riverpod
TrainerCalendarService trainerCalendarService(TrainerCalendarServiceRef ref) => const TrainerCalendarService();
