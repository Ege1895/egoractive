import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// `intl`'in CLDR verisi TRY için hâlâ `TL` döndürüyor (`₺` — Türk Lirası
/// işareti — 2012'de kabul edildi, bu paketin CLDR sürümüne hiç işlenmemiş);
/// tüm locale/versiyonlarda böyle, `intl` sürümü güncellenmeden düzelmiyor.
/// Sadece bu tek durum için sembolü elle eziyoruz — başka hiçbir para
/// birimine dokunulmuyor, onlar zaten `intl`'den doğru geliyor ($, €, £, ¥
/// gibi has bir sembolü olmayanlar için de kısa harf kısaltması, örn. AED
/// için "dh" — kullanıcının istediği "logo yoksa kodu/kısaltmasını yaz"
/// davranışı zaten bu).
const _currencySymbolOverrides = {'TRY': '₺'};

/// F9-1 — global para birimi desteği. Bir salonun bütün tutarları (paket
/// fiyatı, üye ödemesi, gider, rapor toplamları) her zaman tam sayı, kuruş/
/// cent ayrımı yok — bu davranış zaten `ThousandsInputFormatter`'ın öncülü
/// olduğu için değişmiyor, `decimalDigits: 0` bunu her para biriminde
/// zorluyor. Binlik ayracı/sembol pozisyonu `intl`'in CLDR verisinden
/// geliyor, sadece sembolün KENDİSİ [currencySymbol] üzerinden (override'lı)
/// veriliyor.
String formatMoney(int amount, String currencyCode, String locale) {
  return NumberFormat.currency(
    locale: locale,
    symbol: currencySymbol(currencyCode),
    decimalDigits: 0,
  ).format(amount);
}

/// Para birimi sembolü OLMADAN, sadece locale'e uygun binlik ayraçla —
/// eski `formatThousands`'ın (TR'ye özel nokta ayracı) yerini alır.
String formatAmountGrouped(int amount, String locale) {
  return NumberFormat.decimalPattern(locale).format(amount);
}

/// F9-4 — RC'deki alan etiketlerinde ("Tutar (₺)" gibi) para birimini
/// sabit yazmak yerine `{currency}` yer tutucusunu bununla değiştirmek
/// için — [formatMoney] gibi tam bir tutar değil, tek başına sembol.
String currencySymbol(String currencyCode) {
  return _currencySymbolOverrides[currencyCode] ??
      NumberFormat.simpleCurrency(name: currencyCode).currencySymbol;
}

/// [formatEditUpdate] ile yazılan bir metinden ham tam sayıyı geri okumak
/// için — hangi karakterin binlik ayracı olduğu locale'e göre değiştiğinden
/// (TR: nokta, EN: virgül) sabit `'.'` çıkarmak yerine locale'in kendi
/// ayracını kullanır.
int parseMoneyInput(String formattedText, String locale) {
  final groupSeparator = NumberFormat.decimalPattern(locale).symbols.GROUP_SEP;
  final digitsOnly = formattedText
      .replaceAll(groupSeparator, '')
      .replaceAll(RegExp(r'[^0-9]'), '');
  return digitsOnly.isEmpty ? 0 : int.parse(digitsOnly);
}

/// Tutar girişlerinde kullanıcı rakam yazdıkça locale'e uygun binlik ayraç
/// ekler — eski `ThousandsInputFormatter`'ın (hep nokta) yerini alır.
class AppMoneyInputFormatter extends TextInputFormatter {
  AppMoneyInputFormatter({required this.locale});

  final String locale;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final amount = parseMoneyInput(newValue.text, locale);
    if (newValue.text.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final formatted = formatAmountGrouped(amount, locale);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
