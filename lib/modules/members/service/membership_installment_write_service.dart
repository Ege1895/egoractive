import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../shared/domain/membership_installment.dart';

part 'membership_installment_write_service.g.dart';

/// Mevcut bir üyenin `memberPackages/{id}` dokümanındaki tek bir taksiti
/// günceller — [AdminMemberDetailPanel]'in "Ödeme durumu" kartından, paket
/// oluşturma bittikten sonra da admin taksitleri düzenleyebilsin diye.
class MembershipInstallmentWriteService {
  const MembershipInstallmentWriteService();

  Future<void> updateInstallment({
    required String packageDocId,
    required int index,
    required int amountTl,
    required DateTime dueDate,
    required bool paid,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('memberPackages')
        .doc(packageDocId);
    final snapshot = await docRef.get();
    final data = snapshot.data();
    if (data == null) return;

    final installments =
        (data['installments'] as List?)?.cast<Map<String, dynamic>>() ??
        const [];
    final updated = [
      for (final map in installments)
        if ((map['index'] as num).toInt() == index)
          installmentToMap(
            installmentFromMap(
              map,
            ).copyWith(amountTl: amountTl, dueDate: dueDate, paid: paid),
          )
        else
          map,
    ];
    final paidTotal = updated
        .where((map) => map['paid'] == true)
        .fold<int>(0, (total, map) => total + (map['amountTl'] as num).toInt());
    final totalAmount = (data['totalAmount'] as num?)?.toInt() ?? 0;

    await docRef.update({
      'installments': updated,
      'paidAmount': paidTotal,
      'dueAmount': (totalAmount - paidTotal).clamp(0, totalAmount),
    });
  }

  /// Toplam tutarı ve taksit planının tamamını değiştirir —
  /// [EditMemberPaymentPanel]'in "Kaydet" butonu, eski üyeliklerde hiç
  /// taksit kaydı olmayan (yalnızca `totalAmount`/`paidAmount` alanları
  /// dolu) durumu da ilk kez taksitli hale getirebilsin diye.
  Future<void> setInstallmentPlan({
    required String packageDocId,
    required int totalAmountTl,
    required List<MembershipInstallment> installments,
  }) async {
    final paidTotal = installments
        .where((installment) => installment.paid)
        .fold<int>(0, (total, installment) => total + installment.amountTl);
    await FirebaseFirestore.instance
        .collection('memberPackages')
        .doc(packageDocId)
        .update({
          'totalAmount': totalAmountTl,
          'installments': installments.map(installmentToMap).toList(),
          'paidAmount': paidTotal,
          'dueAmount': (totalAmountTl - paidTotal).clamp(0, totalAmountTl),
        });
  }
}

@riverpod
MembershipInstallmentWriteService membershipInstallmentWriteService(
  MembershipInstallmentWriteServiceRef ref,
) {
  return const MembershipInstallmentWriteService();
}
