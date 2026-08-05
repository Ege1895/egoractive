import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_group_session.dart';

part 'admin_group_sessions_service.g.dart';

/// Mock servis — F2'de gerçek `group_sessions` koleksiyonuna bağlanacak.
class AdminGroupSessionsService {
  const AdminGroupSessionsService();

  List<AdminGroupSession> loadGroupSessions() {
    return const [
      AdminGroupSession(id: 'reformer-grup', name: 'Reformer Grup', meta: 'Selin Kara · Pazartesi 14:00 · Stüdyo 1', taken: 6, capacity: 8),
      AdminGroupSession(id: 'fonksiyonel-grup', name: 'Fonksiyonel Grup', meta: 'Selin Kara · Salı 10:00 · Stüdyo 1', taken: 5, capacity: 12),
      AdminGroupSession(id: 'yoga-akisi', name: 'Yoga Akışı', meta: 'Ayşe Demir · Çarşamba 19:00 · Stüdyo 2', taken: 10, capacity: 10),
      AdminGroupSession(id: 'kickbox-temel', name: 'Kickbox Temel', meta: 'Ayşe Demir · Perşembe 18:00 · Stüdyo 1', taken: 3, capacity: 10),
    ];
  }
}

@riverpod
AdminGroupSessionsService adminGroupSessionsService(AdminGroupSessionsServiceRef ref) => const AdminGroupSessionsService();
