import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_notification.dart';
import '../repository/trainer_notifications_repository.dart';

part 'trainer_notifications_controller.g.dart';

@riverpod
class TrainerNotificationsController extends _$TrainerNotificationsController {
  @override
  List<TrainerNotification> build() => ref.watch(trainerNotificationsRepositoryProvider).loadNotifications();
}
