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
        3: [
          ScheduleSlot(
            id: 'w-3-1',
            time: '09:00',
            name: 'Zeynep Kaya',
            meta: 'Birebir · Stüdyo 1',
            state: ScheduleSlotState.completed,
            startTime: DateTime(2026, 8, 3, 9, 0),
          ),
          ScheduleSlot(
            id: 'w-3-2',
            time: '18:30',
            name: 'Ayşe Yılmaz',
            meta: 'Birebir · Stüdyo 2',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 3, 18, 30),
          ),
        ],
        4: [
          ScheduleSlot(
            id: 'w-4-1',
            time: '10:00',
            name: 'Reformer Grup',
            meta: '6/8 kişi · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 4, 10, 0),
          ),
        ],
        5: [],
        6: [
          ScheduleSlot(
            id: 'w-6-1',
            time: '09:00',
            name: 'Zeynep Kaya',
            meta: 'Birebir · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 6, 9, 0),
          ),
          ScheduleSlot(
            id: 'w-6-2',
            time: '16:00',
            name: 'Cem Demir',
            meta: 'Birebir · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 6, 16, 0),
          ),
        ],
        7: [
          ScheduleSlot(
            id: 'w-7-1',
            time: '18:30',
            name: 'Ayşe Yılmaz',
            meta: 'Birebir · Stüdyo 2',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 7, 18, 30),
          ),
        ],
        8: [],
        9: [
          ScheduleSlot(
            id: 'w-9-1',
            time: '11:00',
            name: 'Fonksiyonel Grup',
            meta: '5/12 kişi · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 9, 11, 0),
          ),
        ],
        12: [
          ScheduleSlot(
            id: 'm-12-1',
            time: '10:00',
            name: 'Mert Arslan',
            meta: 'Birebir · Stüdyo 2',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 12, 10, 0),
          ),
        ],
        18: [
          ScheduleSlot(
            id: 'm-18-1',
            time: '09:00',
            name: 'Zeynep Kaya',
            meta: 'Birebir · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 18, 9, 0),
          ),
          ScheduleSlot(
            id: 'm-18-2',
            time: '19:00',
            name: 'Cem Demir',
            meta: 'Birebir · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 18, 19, 0),
          ),
        ],
        24: [
          ScheduleSlot(
            id: 'm-24-1',
            time: '10:00',
            name: 'Reformer Grup',
            meta: '7/8 kişi · Stüdyo 1',
            state: ScheduleSlotState.planned,
            startTime: DateTime(2026, 8, 24, 10, 0),
          ),
        ],
      },
    );
  }
}

@riverpod
TrainerCalendarService trainerCalendarService(TrainerCalendarServiceRef ref) =>
    const TrainerCalendarService();
