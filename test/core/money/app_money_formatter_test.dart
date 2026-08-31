import 'package:flutter_test/flutter_test.dart';

import 'package:egoractive/core/money/app_money_formatter.dart';

void main() {
  group('formatMoney', () {
    test('TRY / tr locale uses the Turkish grouping and symbol', () {
      // intl'in CLDR verisi tr locale'inde TRY için "TL" kısaltmasını
      // kullanıyor (₺ glifi değil) — bu intl'in kendi kararı, bizim
      // elle bir sembol tablosu tutmadığımızın kanıtı.
      final result = formatMoney(50000, 'TRY', 'tr');
      expect(result, contains('50.000'));
      expect(result, contains('TL'));
    });

    test('USD / en locale uses the English grouping and symbol', () {
      final result = formatMoney(50000, 'USD', 'en');
      expect(result, contains('50,000'));
      expect(result, contains(r'$'));
    });

    test(
      'JPY has no decimal digits regardless of decimalDigits:0 override',
      () {
        final result = formatMoney(1500, 'JPY', 'en');
        expect(result, isNot(contains('.')));
      },
    );

    test(
      'never shows decimal digits even for a normally-2-decimal currency',
      () {
        final result = formatMoney(1500, 'EUR', 'en');
        expect(result, isNot(contains('.')));
        expect(result, isNot(contains(',00')));
      },
    );

    test(
      'never shows decimal digits for a normally-3-decimal currency (KWD)',
      () {
        final result = formatMoney(1500, 'KWD', 'en');
        expect(result, isNot(contains('.')));
      },
    );

    test('GBP / en locale uses the pound symbol', () {
      final result = formatMoney(2500, 'GBP', 'en');
      expect(result, contains('£'));
      expect(result, contains('2,500'));
    });
  });

  group('formatAmountGrouped', () {
    test('tr locale groups with a dot', () {
      expect(formatAmountGrouped(1234567, 'tr'), '1.234.567');
    });

    test('en locale groups with a comma', () {
      expect(formatAmountGrouped(1234567, 'en'), '1,234,567');
    });
  });

  group('parseMoneyInput', () {
    test('strips the tr grouping separator', () {
      expect(parseMoneyInput('1.234.567', 'tr'), 1234567);
    });

    test('strips the en grouping separator', () {
      expect(parseMoneyInput('1,234,567', 'en'), 1234567);
    });

    test('empty input parses to 0', () {
      expect(parseMoneyInput('', 'tr'), 0);
    });
  });

  group('AppMoneyInputFormatter', () {
    test(
      'formats digits with the locale grouping separator as the user types',
      () {
        final formatter = AppMoneyInputFormatter(locale: 'tr');
        final result = formatter.formatEditUpdate(
          TextEditingValue.empty,
          const TextEditingValue(text: '1234567'),
        );
        expect(result.text, '1.234.567');
      },
    );
  });
}
