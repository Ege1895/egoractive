import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/report_recipients.dart';

part 'report_recipients_service.g.dart';

/// F5-2 — `gyms/{gymId}.reportEmails` alanı. Haftalık rapor Cloud
/// Function'ları (`weekly-gym-report`, `weekly-accounting-report`) bu
/// alanı okuyup e-postayı buradan alır.
class ReportRecipientsService {
  const ReportRecipientsService();

  Stream<ReportRecipients> watchRecipients(String gymId) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).snapshots().map((doc) {
      final data = doc.data()?['reportEmails'] as Map<String, dynamic>?;
      return ReportRecipients(
        gymReportEmail: (data?['gym'] as String?) ?? '',
        accountingReportEmail: (data?['accounting'] as String?) ?? '',
      );
    });
  }

  Future<void> saveRecipients(String gymId, ReportRecipients recipients) {
    return FirebaseFirestore.instance.collection('gyms').doc(gymId).set({
      'reportEmails': {
        'gym': recipients.gymReportEmail,
        'accounting': recipients.accountingReportEmail,
      },
    }, SetOptions(merge: true));
  }
}

@riverpod
ReportRecipientsService reportRecipientsService(ReportRecipientsServiceRef ref) => const ReportRecipientsService();
