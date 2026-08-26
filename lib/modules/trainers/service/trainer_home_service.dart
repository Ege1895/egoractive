import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/pending_confirmation.dart';
import '../domain/schedule_slot.dart';
import '../domain/trainer_home_state.dart';

part 'trainer_home_service.g.dart';

/// Mock servis — F3'te gerçek `sessions` koleksiyonuna bağlanacak.
class TrainerHomeService {
  const TrainerHomeService();

  TrainerHomeState loadInitial() {
    return TrainerHomeState(
      todaySessionCount: 5,
      completedCount: 2,
      freeSlotCount: 3,
      pendingConfirmations: const [
        PendingConfirmation(
          id: 'pending-1',
          memberId: 'mock-cem-demir',
          memberInitials: 'CD',
          memberName: 'Cem Demir',
          meta: 'Birebir · dün tamamlandı mı?',
          time: '16:00',
          remainingBefore: 2,
        ),
        PendingConfirmation(
          id: 'pending-2',
          memberId: 'mock-zeynep-kaya',
          memberInitials: 'ZK',
          memberName: 'Zeynep Kaya',
          meta: 'Birebir · dün tamamlandı mı?',
          time: '09:00',
          remainingBefore: 9,
        ),
      ],
      todaySchedule: [
        ScheduleSlot(id: 's-1', time: '09:00', name: 'Zeynep Kaya', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.completed, startTime: DateTime(2026, 8, 3, 9, 0)),
        ScheduleSlot(id: 's-2', time: '11:30', name: 'Mert Arslan', meta: 'Birebir · Stüdyo 2', state: ScheduleSlotState.completed, startTime: DateTime(2026, 8, 3, 11, 30)),
        ScheduleSlot(id: 's-3', time: '14:00', name: 'Reformer Grup', meta: '6/8 kişi · Stüdyo 1', state: ScheduleSlotState.current, startTime: DateTime(2026, 8, 3, 14, 0)),
        ScheduleSlot(id: 's-4', time: '18:30', name: 'Ayşe Yılmaz', meta: 'Birebir · Stüdyo 2', state: ScheduleSlotState.planned, startTime: DateTime(2026, 8, 3, 18, 30)),
        ScheduleSlot(id: 's-5', time: '20:00', name: 'Cem Demir', meta: 'Birebir · Stüdyo 1', state: ScheduleSlotState.planned, startTime: DateTime(2026, 8, 3, 20, 0)),
      ],
    );
  }
}

@riverpod
TrainerHomeService trainerHomeService(TrainerHomeServiceRef ref) => const TrainerHomeService();
