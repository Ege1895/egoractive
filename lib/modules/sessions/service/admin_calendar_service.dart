import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_calendar_state.dart';

part 'admin_calendar_service.g.dart';

/// Mock servis — F2'de gerçek `sessions` koleksiyonundan salon çapında
/// (tüm antrenörler) aya göre çekecek.
class AdminCalendarService {
  const AdminCalendarService();

  AdminCalendarState loadInitial() {
    return AdminCalendarState(
      selectedDate: DateTime(2026, 8, 3),
      slotsByDayOfMonth: {
        3: const [
          AdminSessionSlot(
            id: 'a-3-1',
            time: '09:00',
            title: 'Zeynep Kaya',
            meta: 'Berk Aydın · Birebir · Stüdyo 1',
            state: AdminSessionState.completed,
          ),
          AdminSessionSlot(
            id: 'a-3-2',
            time: '14:00',
            title: 'Reformer Grup',
            meta: 'Selin Kara · 6/8 kişi · Stüdyo 1',
            state: AdminSessionState.current,
          ),
          AdminSessionSlot(
            id: 'a-3-3',
            time: '18:30',
            title: 'Ayşe Yılmaz',
            meta: 'Berk Aydın · Birebir · Stüdyo 2',
            state: AdminSessionState.planned,
          ),
          AdminSessionSlot(
            id: 'a-3-4',
            time: '20:00',
            title: 'Cem Demir',
            meta: 'Berk Aydın · Birebir · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
        ],
        4: const [
          AdminSessionSlot(
            id: 'a-4-1',
            time: '10:00',
            title: 'Fonksiyonel Grup',
            meta: 'Selin Kara · 5/12 kişi · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
        ],
        6: const [
          AdminSessionSlot(
            id: 'a-6-1',
            time: '09:00',
            title: 'Zeynep Kaya',
            meta: 'Berk Aydın · Birebir · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
          AdminSessionSlot(
            id: 'a-6-2',
            time: '16:00',
            title: 'Cem Demir',
            meta: 'Berk Aydın · Birebir · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
        ],
        12: const [
          AdminSessionSlot(
            id: 'a-12-1',
            time: '10:00',
            title: 'Mert Arslan',
            meta: 'Berk Aydın · Birebir · Stüdyo 2',
            state: AdminSessionState.planned,
          ),
        ],
        18: const [
          AdminSessionSlot(
            id: 'a-18-1',
            time: '09:00',
            title: 'Zeynep Kaya',
            meta: 'Berk Aydın · Birebir · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
          AdminSessionSlot(
            id: 'a-18-2',
            time: '19:00',
            title: 'Cem Demir',
            meta: 'Berk Aydın · Birebir · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
        ],
        24: const [
          AdminSessionSlot(
            id: 'a-24-1',
            time: '10:00',
            title: 'Reformer Grup',
            meta: 'Selin Kara · 7/8 kişi · Stüdyo 1',
            state: AdminSessionState.planned,
          ),
        ],
      },
    );
  }
}

@riverpod
AdminCalendarService adminCalendarService(AdminCalendarServiceRef ref) =>
    const AdminCalendarService();
