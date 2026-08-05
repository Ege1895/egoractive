import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/admin_feedback_entry.dart';

part 'admin_feedback_service.g.dart';

/// Mock servis — F2'de gerçek `feedback` koleksiyonuna bağlanacak.
class AdminFeedbackService {
  const AdminFeedbackService();

  AdminFeedbackSummary loadSummary() {
    return const AdminFeedbackSummary(
      average: 4.6,
      totalCount: 38,
      starCounts: {5: 24, 4: 9, 3: 3, 2: 1, 1: 1},
      entries: [
        AdminFeedbackEntry(id: 'fb-1', initials: 'AY', memberName: 'Ayşe Yılmaz', meta: '3 Ağustos · Berk Aydın', stars: 5, comment: 'Berk çok ilgili, programım tam bana göre ilerliyor.'),
        AdminFeedbackEntry(id: 'fb-2', initials: 'CD', memberName: 'Cem Demir', meta: '1 Ağustos · Berk Aydın', stars: 4, comment: 'Stüdyo temiz ve düzenli, sadece duş kısmı biraz dar.'),
        AdminFeedbackEntry(id: 'fb-3', initials: 'ZK', memberName: 'Zeynep Kaya', meta: '29 Temmuz · Berk Aydın', stars: 5, comment: 'Reformer grup dersi harika, Selin hoca çok enerjik.'),
        AdminFeedbackEntry(id: 'fb-4', initials: 'MA', memberName: 'Mert Arslan', meta: '25 Temmuz · Berk Aydın', stars: 3, comment: 'Bazı saatlerde stüdyo çok kalabalık oluyor.'),
      ],
    );
  }
}

@riverpod
AdminFeedbackService adminFeedbackService(AdminFeedbackServiceRef ref) => const AdminFeedbackService();
