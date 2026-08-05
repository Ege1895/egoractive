import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/gym_event.dart';

part 'gym_events_service.g.dart';

/// Mock servis — F2'de gerçek `gyms/{gymId}/events` koleksiyonuna bağlanacak.
class GymEventsService {
  const GymEventsService();

  List<GymEvent> loadEvents() {
    return const [
      GymEvent(id: 'belgrad-koşusu', name: 'Belgrad Ormanı Koşusu', location: 'Kemerburgaz, Neşetsuyu girişi', day: '16', month: 'Ağu', meta: '8 km tempolu koşu, ardından esneme.', joined: 22, capacity: 40),
      GymEvent(id: 'beslenme-seminari', name: 'Beslenme Semineri', location: 'Stüdyo 1', day: '23', month: 'Ağu', meta: 'Diyetisyen Elif Kaya ile spor beslenmesi.', joined: 14, capacity: 20),
      GymEvent(id: 'acik-kapi', name: 'Açık Kapı Günü', location: 'Vira Performans Stüdyo', day: '30', month: 'Ağu', meta: 'Yeni üyeler için ücretsiz deneme dersi.', joined: 8),
    ];
  }
}

@riverpod
GymEventsService gymEventsService(GymEventsServiceRef ref) => const GymEventsService();
