import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/create_group_session_form.dart';

part 'create_group_session_service.g.dart';

/// Mock servis — F3'te gerçek `group_sessions` koleksiyonuna yazacak.
class CreateGroupSessionService {
  const CreateGroupSessionService();

  CreateGroupSessionForm loadInitial() {
    return const CreateGroupSessionForm(
      title: '',
      startTime: '09:00',
      durationMinutes: 60,
      selectedDays: {},
      capacity: 1,
      capacityMax: 20,
      onlineBookingEnabled: true,
      studioName: '',
    );
  }
}

@riverpod
CreateGroupSessionService createGroupSessionService(
  CreateGroupSessionServiceRef ref,
) {
  return const CreateGroupSessionService();
}
