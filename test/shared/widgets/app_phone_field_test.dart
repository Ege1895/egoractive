import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:egoractive/core/theme/app_color_scheme.dart';
import 'package:egoractive/core/theme/app_theme.dart';
import 'package:egoractive/core/theme/app_typography.dart';
import 'package:egoractive/shared/widgets/app_phone_field.dart';
import 'package:egoractive/shared/widgets/app_phone_field_prefs.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('tr'), Locale('en')],
    theme: AppTheme.build(
      colors: AppColorScheme.defaultScheme(),
      typography: AppTypography.standard(),
    ),
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      ...PhoneFieldLocalization.delegates,
    ],
    home: Scaffold(body: child),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('initialPhoneNumber', () {
    test('returns the existing number when one is given', () {
      final result = initialPhoneNumber('+15551234567');
      expect(result.isoCode, IsoCode.US);
      expect(result.nsn, '5551234567');
    });

    test('falls back to TR with an empty number when nothing is remembered', () async {
      await AppPhoneFieldPrefs.init();
      final result = initialPhoneNumber();
      expect(result.isoCode, IsoCode.TR);
      expect(result.nsn, isEmpty);
    });

    test('uses the last remembered country when no existing number is given', () async {
      SharedPreferences.setMockInitialValues({
        'app_phone_field_last_country_iso': 'US',
      });
      await AppPhoneFieldPrefs.init();
      final result = initialPhoneNumber();
      expect(result.isoCode, IsoCode.US);
      expect(result.nsn, isEmpty);
    });
  });

  testWidgets(
    'selecting a country persists it for the next new entry',
    (tester) async {
      await AppPhoneFieldPrefs.init();
      await tester.pumpWidget(_wrap(const AppPhoneField()));
      await tester.pump();

      await tester.tap(find.byType(CountryButton));
      await tester.pumpAndSettle();

      // Germany ("Almanya") is close enough to the top of the alphabetical
      // (Turkish-sorted) list to be visible without scrolling or searching.
      await tester.tap(find.text('Almanya'));
      await tester.pumpAndSettle();

      expect(AppPhoneFieldPrefs.lastCountryIso, 'DE');
      expect(initialPhoneNumber().isoCode, IsoCode.DE);
    },
  );

  testWidgets('country selector shows Turkish country names when locale is tr', (
    tester,
  ) async {
    await AppPhoneFieldPrefs.init();
    await tester.pumpWidget(_wrap(const AppPhoneField()));
    await tester.pump();

    await tester.tap(find.byType(CountryButton));
    await tester.pumpAndSettle();

    expect(find.text('Almanya'), findsOneWidget);
    expect(find.text('Afganistan'), findsOneWidget);
  });
}
