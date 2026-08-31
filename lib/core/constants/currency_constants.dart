/// F9-1 — global para birimi desteği. Küratörlü ~33 para birimi listesi
/// (B seçeneği, kullanıcıyla netleşen karar) — tam ISO 4217 listesi değil,
/// gerçekçi ilk pazarları kapsayan bir başlangıç. Format kuralları (sembol/
/// ondalık basamak) `intl`'in CLDR verisinden otomatik geliyor, burada
/// sadece kod listesi + görünen isim eşlemesi tutuluyor. Liste ileride tek
/// satır eklemekle genişletilebilir.
library;

/// TRY her zaman ilk sırada/sabit — mevcut kullanıcı tabanının çoğunluğu.
const List<String> supportedCurrencyCodes = [
  'TRY',
  'USD',
  'EUR',
  'CAD',
  'GBP',
  'CHF',
  'SEK',
  'NOK',
  'DKK',
  'PLN',
  'CZK',
  'AED',
  'SAR',
  'QAR',
  'KWD',
  'ILS',
  'AZN',
  'GEL',
  'KZT',
  'RON',
  'BGN',
  'RSD',
  'AUD',
  'NZD',
  'JPY',
  'SGD',
  'HKD',
  'MXN',
  'BRL',
  'ZAR',
  'EGP',
  'INR',
  'RUB',
];

const Map<String, String> currencyNameTr = {
  'TRY': 'Türk Lirası',
  'USD': 'Amerikan Doları',
  'EUR': 'Euro',
  'CAD': 'Kanada Doları',
  'GBP': 'İngiliz Sterlini',
  'CHF': 'İsviçre Frangı',
  'SEK': 'İsveç Kronu',
  'NOK': 'Norveç Kronu',
  'DKK': 'Danimarka Kronu',
  'PLN': 'Polonya Zlotisi',
  'CZK': 'Çek Korunası',
  'AED': 'BAE Dirhemi',
  'SAR': 'Suudi Riyali',
  'QAR': 'Katar Riyali',
  'KWD': 'Kuveyt Dinarı',
  'ILS': 'İsrail Şekeli',
  'AZN': 'Azerbaycan Manatı',
  'GEL': 'Gürcistan Larisi',
  'KZT': 'Kazakistan Tengesi',
  'RON': 'Romanya Leyi',
  'BGN': 'Bulgaristan Levası',
  'RSD': 'Sırbistan Dinarı',
  'AUD': 'Avustralya Doları',
  'NZD': 'Yeni Zelanda Doları',
  'JPY': 'Japon Yeni',
  'SGD': 'Singapur Doları',
  'HKD': 'Hong Kong Doları',
  'MXN': 'Meksika Pesosu',
  'BRL': 'Brezilya Reali',
  'ZAR': 'Güney Afrika Randı',
  'EGP': 'Mısır Lirası',
  'INR': 'Hindistan Rupisi',
  'RUB': 'Rus Rublesi',
};

const Map<String, String> currencyNameEn = {
  'TRY': 'Turkish Lira',
  'USD': 'US Dollar',
  'EUR': 'Euro',
  'CAD': 'Canadian Dollar',
  'GBP': 'British Pound',
  'CHF': 'Swiss Franc',
  'SEK': 'Swedish Krona',
  'NOK': 'Norwegian Krone',
  'DKK': 'Danish Krone',
  'PLN': 'Polish Zloty',
  'CZK': 'Czech Koruna',
  'AED': 'UAE Dirham',
  'SAR': 'Saudi Riyal',
  'QAR': 'Qatari Riyal',
  'KWD': 'Kuwaiti Dinar',
  'ILS': 'Israeli Shekel',
  'AZN': 'Azerbaijani Manat',
  'GEL': 'Georgian Lari',
  'KZT': 'Kazakhstani Tenge',
  'RON': 'Romanian Leu',
  'BGN': 'Bulgarian Lev',
  'RSD': 'Serbian Dinar',
  'AUD': 'Australian Dollar',
  'NZD': 'New Zealand Dollar',
  'JPY': 'Japanese Yen',
  'SGD': 'Singapore Dollar',
  'HKD': 'Hong Kong Dollar',
  'MXN': 'Mexican Peso',
  'BRL': 'Brazilian Real',
  'ZAR': 'South African Rand',
  'EGP': 'Egyptian Pound',
  'INR': 'Indian Rupee',
  'RUB': 'Russian Ruble',
};

const String defaultCurrencyCode = 'TRY';

/// Uygulama dili TR/EN dışında bir şey olamayacağı için (bkz. `main.dart`
/// `supportedLocales`) sadece bu iki dilin eşlemesi tutuluyor.
String currencyDisplayName(String currencyCode, String locale) {
  final map = locale == 'tr' ? currencyNameTr : currencyNameEn;
  return map[currencyCode] ?? currencyCode;
}
