/// Bir seans tamamlanma yazımının, üyenin kalan ders toplamını (admin
/// Üyeler listesindeki "Bitiyor"/"Paketi yok" ile birebir aynı hesap, bkz.
/// `admin_member_summary_mapper.dart`) "bitiyor" ya da "bitti" eşiğinin
/// AŞAĞI doğru YENİ geçtiği bir noktaya getirip getirmediğini belirler.
enum MemberPackageAlert { endingSoon, none }

/// Saf karar mantığı — Cloud Functions tarafındaki (artık kaldırılan)
/// `onMemberPackageQuotaChanged` trigger'ının client tarafına taşınmış hâli.
/// Sadece AZALIŞ ilgilendiriyor — bir paket eklenip toplam yükseldiğinde
/// (ör. none'dan endingSoon'a çıksa bile) asla bildirim üretilmez. Ayrıca
/// zaten "endingSoon" durumundayken tek tek azalan her seansta tekrar
/// tekrar bildirim üretilmesin diye sadece eşiği O AN yeni geçen durumlar
/// sinyal üretir — halihazırda eşiğin altındaysa (ör. 2 kalan → 1 kalan)
/// `null` döner.
MemberPackageAlert? resolveMemberPackageAlert({
  required int beforeTotal,
  required int afterTotal,
  required int endingSoonThreshold,
}) {
  if (afterTotal >= beforeTotal) return null;

  if (beforeTotal > 0 && afterTotal <= 0) return MemberPackageAlert.none;

  final wasAboveThreshold = beforeTotal > endingSoonThreshold;
  if (wasAboveThreshold && afterTotal > 0 && afterTotal <= endingSoonThreshold) {
    return MemberPackageAlert.endingSoon;
  }

  return null;
}
