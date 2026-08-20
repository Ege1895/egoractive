import 'package:flutter/services.dart';

/// 10 haneli Türkiye cep telefonu numarasını "5XX XXX XX XX" olarak gruplar.
String formatTrPhoneDigits(String digits) {
  const groups = [3, 3, 2, 2];
  var rest = digits;
  final parts = <String>[];
  for (final g in groups) {
    if (rest.isEmpty) break;
    final take = g > rest.length ? rest.length : g;
    parts.add(rest.substring(0, take));
    rest = rest.substring(take);
  }
  return parts.join(' ');
}

/// Firestore'da saklanan ham numarayı (`+905551234567` gibi) görüntüleme
/// için "555 123 45 67" haline getirir — ülke kodu/başındaki 0 atılır, son
/// 10 hane gruplanır. Ölçüm/üye/antrenör detay ekranlarında telefon
/// gösterilen her yerde kullanılır.
String formatTrPhoneDisplay(String rawPhone) {
  final digitsOnly = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
  final last10 = digitsOnly.length > 10
      ? digitsOnly.substring(digitsOnly.length - 10)
      : digitsOnly;
  return formatTrPhoneDigits(last10);
}

/// Kullanıcı yazdıkça haneleri "5XX XXX XX XX" olarak gruplar — telefon
/// numarasıyla giriş yapılan her yerde (Telefonla Giriş, Salon Kurulumu)
/// aynı davranışı garanti etmek için ortak bir formatter.
class TrPhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final limited = digits.length > 10 ? digits.substring(0, 10) : digits;
    final formatted = formatTrPhoneDigits(limited);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
