import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/trainer_notification.dart';

part 'trainer_notifications_service.g.dart';

/// Mock servis — F3'te gerçek FCM/Firestore bildirim akışına bağlanacak.
class TrainerNotificationsService {
  const TrainerNotificationsService();

  List<TrainerNotification> loadNotifications() {
    return const [
      TrainerNotification(
        id: 'notif-1',
        title: 'Ayşe Yılmaz geleceğini bildirdi',
        body: '4 Ağustos 18:30 · Birebir · Stüdyo 2',
        memberInitials: 'AY',
        memberName: 'Ayşe Yılmaz',
        sessionMeta: '4 Ağustos 18:30 · Birebir · Stüdyo 2',
        answerLabel: 'Gelicem',
        answerIsPositive: true,
        answeredAt: '3 Ağu 21:04',
        note: '5 dakika gecikebilirim, trafik yoğun.',
      ),
      TrainerNotification(
        id: 'notif-2',
        title: 'Cem Demir gelmeyeceğini bildirdi',
        body: '5 Ağustos 16:00 · Birebir · Stüdyo 1',
        memberInitials: 'CD',
        memberName: 'Cem Demir',
        sessionMeta: '5 Ağustos 16:00 · Birebir · Stüdyo 1',
        answerLabel: 'Gelmeyeceğim',
        answerIsPositive: false,
        answeredAt: '3 Ağu 19:40',
        note: null,
      ),
      TrainerNotification(
        id: 'notif-3',
        title: 'Zeynep Kaya geleceğini bildirdi',
        body: '6 Ağustos 09:00 · Birebir · Stüdyo 1',
        memberInitials: 'ZK',
        memberName: 'Zeynep Kaya',
        sessionMeta: '6 Ağustos 09:00 · Birebir · Stüdyo 1',
        answerLabel: 'Gelicem',
        answerIsPositive: true,
        answeredAt: '3 Ağu 18:12',
        note: null,
      ),
    ];
  }
}

@riverpod
TrainerNotificationsService trainerNotificationsService(
  TrainerNotificationsServiceRef ref,
) {
  return const TrainerNotificationsService();
}
