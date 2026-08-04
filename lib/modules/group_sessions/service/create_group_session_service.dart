import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/create_group_session_form.dart';

part 'create_group_session_service.g.dart';

/// Mock servis — F3'te gerçek `group_sessions` koleksiyonuna yazacak.
class CreateGroupSessionService {
  const CreateGroupSessionService();

  CreateGroupSessionForm loadInitial() {
    return const CreateGroupSessionForm(
      title: 'Fonksiyonel Grup',
      startTime: '07:30',
      durationMinutes: 45,
      selectedDays: {1, 3, 5},
      capacity: 8,
      capacityMax: 12,
      onlineBookingEnabled: true,
      studioName: 'Stüdyo 1',
    );
  }
}

@riverpod
CreateGroupSessionService createGroupSessionService(CreateGroupSessionServiceRef ref) {
  return const CreateGroupSessionService();
}
