import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/report_recipients.dart';

part 'report_recipients_service.g.dart';

/// F5-2/F5-15 — `gyms/{gymId}.reportEmails.gym` alanı. Haftalık/aylık rapor
/// Cloud Function'ları (`weekly-gym-report`, `monthly-gym-report`) bu alanı
/// okuyup e-postayı buradan alır.
class ReportRecipientsService {
  const ReportRecipientsService();

  Stream<ReportRecipients> watchRecipients(String gymId) {
    return FirebaseFirestore.instance
        .collection('gyms')
        .doc(gymId)
        .snapshots()
        .map((doc) {
          final data = doc.data()?['reportEmails'] as Map<String, dynamic>?;
          return ReportRecipients(
            gymReportEmail: (data?['gym'] as String?) ?? '',
          );
        });
  }

  Future<void> saveRecipients(String gymId, ReportRecipients recipients) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
      'reportEmails': {'gym': recipients.gymReportEmail},
    }, SetOptions(merge: true));
  }
}

@riverpod
ReportRecipientsService reportRecipientsService(
  ReportRecipientsServiceRef ref,
) => const ReportRecipientsService();
