import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/discover_item.dart';

part 'discover_service.g.dart';

/// Mock servis — F4-2'de `group_sessions`/`events` koleksiyonlarına
/// bağlanacak (kontenjan mantığı `CapacityService` ile ortaklanacak).
class DiscoverService {
  const DiscoverService();

  List<DiscoverItem> loadItems() {
    return const [
      DiscoverItem(
        id: 'reformer',
        category: DiscoverCategory.groupSessions,
        day: '10',
        month: 'Ağu',
        title: 'Reformer Grup',
        meta: 'Selin Kara · Pazartesi 10:00 · 50 dk',
        taken: 6,
        capacity: 8,
      ),
      DiscoverItem(
        id: 'mat',
        category: DiscoverCategory.groupSessions,
        day: '11',
        month: 'Ağu',
        title: 'Mat Pilates',
        meta: 'Selin Kara · Salı 19:00 · 50 dk',
        taken: 8,
        capacity: 8,
      ),
      DiscoverItem(
        id: 'fonksiyonel',
        category: DiscoverCategory.groupSessions,
        day: '13',
        month: 'Ağu',
        title: 'Fonksiyonel Grup',
        meta: 'Berk Aydın · Perşembe 07:30 · 45 dk',
        taken: 3,
        capacity: 10,
      ),
      DiscoverItem(
        id: 'kosu',
        category: DiscoverCategory.events,
        day: '16',
        month: 'Ağu',
        title: 'Belgrad Ormanı Koşusu',
        meta: 'Kemerburgaz · Cumartesi 08:00 · 8 km',
        taken: 14,
        capacity: 20,
      ),
      DiscoverItem(
        id: 'brunch',
        category: DiscoverCategory.events,
        day: '23',
        month: 'Ağu',
        title: 'Stüdyo Brunch',
        meta: 'Vira Stüdyo bahçesi · Cumartesi 11:00',
        taken: 22,
        capacity: 25,
      ),
    ];
  }
}

@riverpod
DiscoverService discoverService(DiscoverServiceRef ref) => const DiscoverService();
