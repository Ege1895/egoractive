import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_notification.dart';
import '../service/trainer_notifications_service.dart';

part 'trainer_notifications_repository.g.dart';

abstract interface class TrainerNotificationsRepository {
  List<TrainerNotification> loadNotifications();
}

class TrainerNotificationsRepositoryImpl implements TrainerNotificationsRepository {
  const TrainerNotificationsRepositoryImpl(this._service);

  final TrainerNotificationsService _service;

  @override
  List<TrainerNotification> loadNotifications() => _service.loadNotifications();
}

@riverpod
TrainerNotificationsRepository trainerNotificationsRepository(TrainerNotificationsRepositoryRef ref) {
  return TrainerNotificationsRepositoryImpl(ref.watch(trainerNotificationsServiceProvider));
}
