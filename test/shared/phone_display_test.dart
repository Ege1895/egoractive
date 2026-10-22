import 'package:egoractive/shared/utils/phone_display.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Kullanıcı raporu (2026-09-05): profilde "+90 +905335106907 · Üye"
  // görünüyordu — RC şablonundaki sabit "+90 " ön eki, E.164 numaranın
  // üstüne biniyordu. Artık ülke kodu numaranın kendisinden geliyor.
  test('E.164 TR numarası okunur biçimde gruplanır', () {
    expect(formatPhoneForDisplay('+905335106907'), '+90 533 510 69 07');
  });

  test('araya boşluk/tire karışmış E.164 de aynı sonucu verir', () {
    expect(formatPhoneForDisplay(' +90 533 510 69 07 '), '+90 533 510 69 07');
    expect(formatPhoneForDisplay('+90-533-510-69-07'), '+90 533 510 69 07');
  });

  // Migrasyon öncesi kayıtlarda numara çıplak 10 hane olabiliyor.
  test('çıplak 10 haneli TR numarası 0 ile gösterilir', () {
    expect(formatPhoneForDisplay('5335106907'), '0533 510 69 07');
  });

  // Türkiye dışı numaralarda gruplama tahmin edilmiyor.
  test('yabancı numara E.164 hâliyle döner', () {
    expect(formatPhoneForDisplay('+14155552671'), '+14155552671');
    expect(formatPhoneForDisplay('+442071838750'), '+442071838750');
  });

  test('boş/eksik değerde çökmez', () {
    expect(formatPhoneForDisplay(''), '');
    expect(formatPhoneForDisplay('   '), '');
    expect(formatPhoneForDisplay('123'), '123');
  });
}
