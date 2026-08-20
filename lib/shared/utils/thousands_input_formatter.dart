import 'package:flutter/services.dart';

/// Bir tam sayıyı görüntülemek için binlik nokta ayraçlarıyla biçimlendirir
/// (₺20000 → "20.000"). [ThousandsInputFormatter] input alanları için;
/// bu, salt-okunur `Text` gösterimleri için (ör. Giderler ekranı).
String formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) buffer.write('.');
  }
  return value < 0 ? '-${buffer.toString()}' : buffer.toString();
}

/// Tutar girişlerinde kullanıcı rakam yazdıkça binlik ayraç (nokta) ekler —
/// ör. "100000" yazılırken ekranda "100.000" görünür. Kullanıcı hiçbir zaman
/// nokta tuşuna basmaz, sadece rakam girer; gerçek (ayraçsız) değer
/// `controller.text.replaceAll('.', '')` ile okunur.
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final buffer = StringBuffer();
    for (var i = 0; i < digitsOnly.length; i++) {
      final indexFromEnd = digitsOnly.length - i;
      buffer.write(digitsOnly[i]);
      if (indexFromEnd > 1 && indexFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
