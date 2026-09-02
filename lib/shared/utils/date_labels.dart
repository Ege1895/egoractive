import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/remote_config/remote_config_service.dart';

part 'date_labels.g.dart';

/// Uygulamadaki TÜM ay/gün adları ve kısa tarih biçimleri buradan geçer.
///
/// Daha önce her modül kendi Türkçe `const _monthNames = {1: 'Ocak', ...}`
/// map'ini taşıyordu (25 dosya) — uygulama İngilizce'yken bile tarihler
/// Türkçe görünüyordu (kullanıcı raporu, 2026-09-02). Adlar artık Remote
/// Config'ten, aktif dile göre geliyor.
///
/// Gün/ay sırası da dile bağlı: Türkçe "30 Ağu 2026", İngilizce "Aug 30,
/// 2026". Bu yüzden dizilim de RC'de şablon olarak duruyor, kodda `'$day
/// $month'` gibi sabit bir kurgu yok.
///
/// Sınır kontrolleri şart: RC hazır değilse (Firebase başlatılmamış test
/// ortamı, ilk kare) `rcTextProvider` boş string döner ve `''.split(',')`
/// TEK elemanlı liste verir — doğrudan indeksleme RangeError ile paneli
/// çökertirdi. Böyle bir durumda ad yerine sayısal yedeğe düşülür.
class DateLabels {
  const DateLabels({
    required this.monthsLong,
    required this.monthsShort,
    required this.weekdaysLong,
    required this.weekdaysShort,
    required this.dayMonthYearTemplate,
    required this.dayMonthTemplate,
    required this.weekdaysInitial,
    required this.weekdayDateTemplate,
  });

  /// Test ve RC'siz ortamlar için — her şey sayısal yedeğe düşer.
  static const empty = DateLabels(
    monthsLong: '',
    monthsShort: '',
    weekdaysLong: '',
    weekdaysShort: '',
    dayMonthYearTemplate: '',
    dayMonthTemplate: '',
    weekdaysInitial: '',
    weekdayDateTemplate: '',
  );

  final String monthsLong;
  final String monthsShort;
  final String weekdaysLong;
  final String weekdaysShort;
  final String dayMonthYearTemplate;
  final String dayMonthTemplate;
  final String weekdaysInitial;
  final String weekdayDateTemplate;

  /// "Eylül" / "September"; RC yoksa ay numarası.
  String monthLong(int month) => _pick(monthsLong, month, '$month');

  /// "Ağu" / "Aug"; RC yoksa ay numarası.
  String monthShort(int month) => _pick(monthsShort, month, '$month');

  /// [DateTime.weekday] 1 = Pazartesi.
  String weekdayLong(int weekday) => _pick(weekdaysLong, weekday, '');

  String weekdayShort(int weekday) => _pick(weekdaysShort, weekday, '');

  /// "Eylül 2026" / "September 2026".
  String monthYear(DateTime date) {
    final name = _pick(monthsLong, date.month, '');
    return name.isEmpty
        ? '${date.month}.${date.year}'
        : '$name ${date.year}';
  }

  /// "30 Ağu 2026" / "Aug 30, 2026".
  String dayMonthYear(DateTime date) => _fill(
    dayMonthYearTemplate,
    '{day} {month} {year}',
    date.day,
    monthShort(date.month),
    date.year,
  );

  /// "30 Ağustos 2026" / "August 30, 2026" — uzun ay adıyla tam tarih.
  String dayMonthYearLong(DateTime date) => _fill(
    dayMonthYearTemplate,
    '{day} {month} {year}',
    date.day,
    monthLong(date.month),
    date.year,
  );

  /// "30 Ağu" / "Aug 30" — yıl gösterilmeyen dar alanlar (liste satırı,
  /// rozet) için kısa ay adıyla.
  String dayMonthShort(DateTime date) =>
      _fill(dayMonthTemplate, '{day} {month}', date.day, monthShort(date.month), null);

  /// "30 Ağustos" / "August 30" — yıl gösterilmeyen yerler için.
  String dayMonthLong(DateTime date) =>
      _fill(dayMonthTemplate, '{day} {month}', date.day, monthLong(date.month), null);

  /// Virgülle ayrılmış 7 kısa gün adı, Pazartesi'den başlayarak — takvim
  /// başlığı satırı bunu doğrudan listeleyecek.
  List<String> get weekdayShortList =>
      List.generate(7, (i) => weekdayShort(i + 1));

  /// "Cumartesi, 30 Ağu" — gün adı + serbest tarih metni.
  String weekdayWithDate(int weekday, String date) {
    final template = weekdayDateTemplate.isEmpty
        ? '{weekday}, {date}'
        : weekdayDateTemplate;
    return template
        .replaceAll('{weekday}', weekdayLong(weekday))
        .replaceAll('{date}', date)
        .trim();
  }

  /// Takvim ızgarasının tek harflik gün başlıkları (Pzt -> Paz).
  List<String> get weekdayInitialList =>
      List.generate(7, (i) => _pick(weekdaysInitial, i + 1, ''));

  String _pick(String csv, int oneBasedIndex, String fallback) {
    final parts = csv.split(',');
    if (oneBasedIndex < 1 || oneBasedIndex > parts.length) return fallback;
    final value = parts[oneBasedIndex - 1].trim();
    return value.isEmpty ? fallback : value;
  }

  String _fill(
    String template,
    String fallbackTemplate,
    int day,
    String month,
    int? year,
  ) {
    final effective = template.isEmpty ? fallbackTemplate : template;
    return effective
        .replaceAll('{day}', '$day')
        .replaceAll('{month}', month)
        .replaceAll('{year}', year == null ? '' : '$year')
        .trim();
  }
}

/// Ay/gün adlarını RC'den okuyan tek kaynak. Widget'lar `ref.watch` ile
/// (dil değişince otomatik yeniden çizilir), controller'lar `ref.read` ile
/// kullanır; RC'ye erişimi olmayan servis katmanına ise parametre olarak
/// geçilir (bkz. `report_pdf_export_service` başındaki aynı gerekçe).
@riverpod
DateLabels dateLabels(DateLabelsRef ref) => DateLabels(
  monthsLong: ref.watch(rcTextProvider(RemoteConfigKeys.commonMonthNamesLong)),
  monthsShort: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonMonthNamesShort),
  ),
  weekdaysLong: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonWeekdayNamesLong),
  ),
  weekdaysShort: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonWeekdayNamesShort),
  ),
  dayMonthYearTemplate: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonDayMonthYearTemplate),
  ),
  dayMonthTemplate: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonDayMonthTemplate),
  ),
  weekdaysInitial: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonWeekdayNamesInitial),
  ),
  weekdayDateTemplate: ref.watch(
    rcTextProvider(RemoteConfigKeys.commonWeekdayDateTemplate),
  ),
);
