import 'package:freezed_annotation/freezed_annotation.dart';

part 'membership_installment.freezed.dart';

/// Bir üyelik paketinin taksitlerinden biri. `members` (admin taksit
/// yönetimi) ve `packages` (üyenin kendi ekranında taksit durumu) modülleri
/// ortak kullandığı için `shared`'da yaşıyor — ikisi arasında doğrudan
/// bağımlılık kurulmasın diye.
@freezed
class MembershipInstallment with _$MembershipInstallment {
  const factory MembershipInstallment({
    required int index,
    required int amountTl,
    required DateTime dueDate,
    required bool paid,
  }) = _MembershipInstallment;
}

/// `memberPackages/{id}.installments` alanındaki bir taksit haritasını
/// domain modeline çevirir.
MembershipInstallment installmentFromMap(Map<String, dynamic> map) {
  return MembershipInstallment(
    index: (map['index'] as num).toInt(),
    amountTl: (map['amountTl'] as num).toInt(),
    dueDate: DateTime.parse(map['dueDate'] as String),
    paid: map['paid'] as bool? ?? false,
  );
}

/// [installmentFromMap]'in tersi — Firestore'a yazılacak haritayı üretir.
Map<String, dynamic> installmentToMap(MembershipInstallment installment) {
  return {
    'index': installment.index,
    'amountTl': installment.amountTl,
    'dueDate': installment.dueDate.toIso8601String(),
    'paid': installment.paid,
  };
}

/// Toplam tutarı [count] taksite mümkün olduğunca eşit böler — bölünemeyen
/// kalan ilk taksitlere birer birim eklenerek dağıtılır (ör. 100/3 →
/// 34, 33, 33), böylece taksitlerin toplamı her zaman tam olarak
/// [totalAmountTl]'e eşit kalır.
List<MembershipInstallment> splitIntoInstallments({
  required int totalAmountTl,
  required int count,
  required DateTime firstDueDate,
}) {
  final clampedCount = count < 1 ? 1 : count;
  final base = totalAmountTl ~/ clampedCount;
  final remainder = totalAmountTl % clampedCount;
  return [
    for (var i = 0; i < clampedCount; i++)
      MembershipInstallment(
        index: i + 1,
        amountTl: base + (i < remainder ? 1 : 0),
        dueDate: DateTime(
          firstDueDate.year,
          firstDueDate.month + i,
          firstDueDate.day,
        ),
        paid: false,
      ),
  ];
}
