import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_home_state.dart';

part 'admin_home_service.g.dart';

/// Mock servis — F3'te gerçek seans/ödeme/geri bildirim koleksiyonlarından
/// hesaplanacak.
class AdminHomeService {
  const AdminHomeService();

  AdminHomeState loadInitial() {
    return const AdminHomeState(
      monthLabel: 'Temmuz 2026 özeti',
      totalSessions: 248,
      completedSessions: 214,
      cancelledSessions: 34,
      estimatedRevenue: '₺386.500',
      revenueChangeLabel: 'Geçen aya göre +%8',
      expenses: '₺142.800',
      trainerPerformance: [
        TrainerPerformance(name: 'Berk Aydın', sessionCount: 96, ratio: 0.9),
        TrainerPerformance(name: 'Selin Kara', sessionCount: 74, ratio: 0.72),
        TrainerPerformance(name: 'Ayşe Demir', sessionCount: 44, ratio: 0.5),
      ],
      duePayments: [
        DuePayment(memberName: 'Ayşe Yılmaz', dueDate: '8 Ağustos', amount: '₺4.800'),
        DuePayment(memberName: 'Cem Demir', dueDate: '10 Ağustos', amount: '₺3.200'),
        DuePayment(memberName: 'Mert Arslan', dueDate: '12 Ağustos', amount: '₺6.000'),
      ],
      pendingFeedbackCount: 5,
      recentFeedbackDays: 7,
    );
  }
}

@riverpod
AdminHomeService adminHomeService(AdminHomeServiceRef ref) => const AdminHomeService();
