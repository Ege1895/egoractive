/// Kayıtlı telefon numarasını ekranda okunur hale getirir.
///
/// `users/{uid}.phoneNumber` E.164 biçiminde saklanıyor (`+905335106907`),
/// ama migrasyon öncesi kayıtlarda çıplak 10 haneli TR numarası da olabilir
/// (bkz. `shared/utils/phone_lookup.dart`) — ikisi de destekleniyor.
///
/// Profil ekranındaki alt satır önceden RC şablonunda SABİT bir `+90 ` ön eki
/// taşıyordu; numara E.164'e geçince "+90 +905335106907" gibi çift ön ekli
/// görünüyordu (kullanıcı raporu, 2026-09-05). Ülke kodu artık numaranın
/// kendisinden geliyor, şablondan değil.
///
/// Türkiye dışı numaralarda gruplama YAPILMIYOR: her ülkenin kendi
/// gruplaması var, tahmin etmek yanlış biçimlendirmeye yol açar. O durumda
/// numara E.164 hâliyle döner — yanlış gruplanmış bir numaradansa ham ama
/// doğru bir numara daha iyi.
String formatPhoneForDisplay(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '';

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');

  // +90 5XX XXX XX XX
  if (digits.length == 12 && digits.startsWith('90')) {
    return '+90 ${_groupTrNational(digits.substring(2))}';
  }

  // Migrasyon öncesi çıplak hâl: 5XX XXX XX XX -> 0 ile gösterilir.
  if (!trimmed.startsWith('+') &&
      digits.length == 10 &&
      digits.startsWith('5')) {
    return '0${_groupTrNational(digits)}';
  }

  return trimmed;
}

/// 10 haneli TR numarasını "533 510 69 07" olarak gruplar (3-3-2-2).
String _groupTrNational(String tenDigits) {
  return '${tenDigits.substring(0, 3)} ${tenDigits.substring(3, 6)} '
      '${tenDigits.substring(6, 8)} ${tenDigits.substring(8)}';
}
