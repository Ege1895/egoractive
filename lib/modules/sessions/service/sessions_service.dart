import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/session.dart';
import '../domain/sessions_state.dart';

part 'sessions_service.g.dart';

/// Mock servis — F3-3/F3-4'te gerçek `sessions` koleksiyonuna bağlanacak.
class SessionsService {
  const SessionsService();

  SessionsState loadInitial() {
    return const SessionsState(
      nextSession: Session(
        id: 'next',
        day: '03',
        month: 'Ağu',
        title: 'Birebir · 18:30',
        meta: 'Berk Aydın · Stüdyo 2',
        status: SessionStatus.planned,
      ),
      upcoming: [
        Session(
          id: 'up-1',
          day: '03',
          month: 'Ağu',
          title: 'Birebir · 18:30',
          meta: 'Berk Aydın · Stüdyo 2',
          status: SessionStatus.planned,
        ),
        Session(
          id: 'up-2',
          day: '06',
          month: 'Ağu',
          title: 'Birebir · 18:30',
          meta: 'Berk Aydın · Stüdyo 2',
          status: SessionStatus.planned,
        ),
        Session(
          id: 'up-3',
          day: '10',
          month: 'Ağu',
          title: 'Reformer Grup · 10:00',
          meta: 'Selin Kara · 6/8 kişi',
          status: SessionStatus.planned,
        ),
      ],
      past: [
        Session(
          id: 'past-1',
          day: '30',
          month: 'Tem',
          title: 'Birebir · 18:30',
          meta: 'Berk Aydın · Stüdyo 2',
          status: SessionStatus.completed,
        ),
        Session(
          id: 'past-2',
          day: '27',
          month: 'Tem',
          title: 'Birebir · 18:30',
          meta: 'Sen iptal ettin',
          status: SessionStatus.cancelled,
        ),
      ],
      week: [
        WeekActivityDay(label: 'Pzt', intensity: 0.76, isRestDay: false),
        WeekActivityDay(label: 'Sal', intensity: 0.12, isRestDay: true),
        WeekActivityDay(label: 'Çar', intensity: 0.58, isRestDay: false),
        WeekActivityDay(label: 'Per', intensity: 0.12, isRestDay: true),
        WeekActivityDay(label: 'Cum', intensity: 0.92, isRestDay: false),
        WeekActivityDay(label: 'Cmt', intensity: 0.12, isRestDay: true),
        WeekActivityDay(label: 'Pzr', intensity: 0.12, isRestDay: true),
      ],
      paymentWarning: PaymentWarning(amount: '₺4.800', dueDate: '8 Ağustos'),
    );
  }
}

@riverpod
SessionsService sessionsService(SessionsServiceRef ref) =>
    const SessionsService();
