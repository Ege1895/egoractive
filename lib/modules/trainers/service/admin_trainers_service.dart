import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_trainer_summary.dart';

part 'admin_trainers_service.g.dart';

/// Mock servis — F2'de gerçek `trainers` koleksiyonuna bağlanacak.
class AdminTrainersService {
  const AdminTrainersService();

  List<AdminTrainerSummary> loadTrainers() {
    return const [
      AdminTrainerSummary(
        id: 'berk-aydin',
        initials: 'BA',
        name: 'Berk Aydın',
        phone: '0532 111 22 33',
        specialties: ['Fonksiyonel'],
        memberCount: 4,
      ),
      AdminTrainerSummary(
        id: 'selin-kara',
        initials: 'SK',
        name: 'Selin Kara',
        phone: '0533 445 56 67',
        specialties: ['Pilates'],
        memberCount: 3,
      ),
      AdminTrainerSummary(
        id: 'ayse-demir',
        initials: 'AD',
        name: 'Ayşe Demir',
        phone: '0544 778 89 90',
        specialties: ['Yoga'],
        memberCount: 2,
      ),
    ];
  }
}

@riverpod
AdminTrainersService adminTrainersService(AdminTrainersServiceRef ref) =>
    const AdminTrainersService();
