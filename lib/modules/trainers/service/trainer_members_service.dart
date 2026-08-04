import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/mock/trainer_mock_data.dart';
import '../domain/trainer_member_summary.dart';

part 'trainer_members_service.g.dart';

/// Mock servis — F3'te bu antrenöre bağlı gerçek üyeleri çekecek.
class TrainerMembersService {
  const TrainerMembersService();

  List<TrainerMemberSummary> loadMembers() {
    return [
      for (final m in TrainerMockData.members)
        TrainerMemberSummary(
          id: m.id,
          initials: m.initials,
          name: m.name,
          packageName: m.packageName,
          remainingSessions: m.remainingSessions,
        ),
    ];
  }
}

@riverpod
TrainerMembersService trainerMembersService(TrainerMembersServiceRef ref) => const TrainerMembersService();
