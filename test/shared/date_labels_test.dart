import 'package:egoractive/shared/utils/date_labels.dart';
import 'package:flutter_test/flutter_test.dart';

const _tr = DateLabels(
  monthsLong:
      'Ocak,Şubat,Mart,Nisan,Mayıs,Haziran,Temmuz,Ağustos,Eylül,Ekim,Kasım,Aralık',
  monthsShort: 'Oca,Şub,Mar,Nis,May,Haz,Tem,Ağu,Eyl,Eki,Kas,Ara',
  weekdaysLong: 'Pazartesi,Salı,Çarşamba,Perşembe,Cuma,Cumartesi,Pazar',
  weekdaysShort: 'Pzt,Sal,Çar,Per,Cum,Cmt,Pzr',
  dayMonthYearTemplate: '{day} {month} {year}',
  dayMonthTemplate: '{day} {month}',
  weekdaysInitial: 'P,S,Ç,P,C,C,P',
  weekdayDateTemplate: '{weekday}, {date}',
);

const _en = DateLabels(
  monthsLong:
      'January,February,March,April,May,June,July,August,September,October,November,December',
  monthsShort: 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec',
  weekdaysLong: 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday',
  weekdaysShort: 'Mon,Tue,Wed,Thu,Fri,Sat,Sun',
  dayMonthYearTemplate: '{month} {day}, {year}',
  dayMonthTemplate: '{month} {day}',
  weekdaysInitial: 'M,T,W,T,F,S,S',
  weekdayDateTemplate: '{weekday}, {date}',
);

void main() {
  final august30 = DateTime(2026, 8, 30); // Pazar

  test('ay adları aktif dile göre gelir', () {
    expect(_tr.monthYear(DateTime(2026, 9)), 'Eylül 2026');
    expect(_en.monthYear(DateTime(2026, 9)), 'September 2026');
    expect(_tr.monthShort(8), 'Ağu');
    expect(_en.monthShort(8), 'Aug');
  });

  test('gün adları 1 = Pazartesi ile eşlenir', () {
    expect(_tr.weekdayLong(1), 'Pazartesi');
    expect(_tr.weekdayLong(7), 'Pazar');
    expect(_en.weekdayLong(3), 'Wednesday');
    expect(_en.weekdayShort(6), 'Sat');
  });

  // Dizilim de dile bağlı: Türkçe gün-ay, İngilizce ay-gün.
  test('kısa tarih dizilimi dile göre değişir', () {
    expect(_tr.dayMonthYear(august30), '30 Ağu 2026');
    expect(_en.dayMonthYear(august30), 'Aug 30, 2026');
    expect(_tr.dayMonthLong(august30), '30 Ağustos');
    expect(_en.dayMonthLong(august30), 'August 30');
  });

  test('gün adı + tarih dizilimi şablondan gelir', () {
    expect(_tr.weekdayWithDate(6, '30 Ağu'), 'Cumartesi, 30 Ağu');
    expect(_en.weekdayWithDate(6, 'Aug 30'), 'Saturday, Aug 30');
  });

  test('takvim başlığı için 7 kısa gün adı sırayla döner', () {
    expect(_tr.weekdayShortList, [
      'Pzt',
      'Sal',
      'Çar',
      'Per',
      'Cum',
      'Cmt',
      'Pzr',
    ]);
    expect(_en.weekdayShortList.first, 'Mon');
    expect(_tr.weekdayInitialList, ['P', 'S', 'Ç', 'P', 'C', 'C', 'P']);
  });

  // RC hazır değilken `rcTextProvider` boş string döner; eskiden bu tür bir
  // liste doğrudan indekslendiği için panel RangeError ile çöküyordu.
  test('RC boşsa çökmez, sayısal/boş yedeğe düşer', () {
    expect(DateLabels.empty.monthYear(DateTime(2026, 9)), '9.2026');
    expect(DateLabels.empty.monthShort(8), '8');
    expect(DateLabels.empty.weekdayLong(1), '');
    expect(DateLabels.empty.dayMonthYear(august30), '30 8 2026');
    expect(_tr.copyWithMonthsShort('Oca,Şub').monthShort(9), '9');
  });
}

extension on DateLabels {
  DateLabels copyWithMonthsShort(String value) => DateLabels(
    monthsLong: monthsLong,
    monthsShort: value,
    weekdaysLong: weekdaysLong,
    weekdaysShort: weekdaysShort,
    dayMonthYearTemplate: dayMonthYearTemplate,
    dayMonthTemplate: dayMonthTemplate,
    weekdaysInitial: weekdaysInitial,
    weekdayDateTemplate: weekdayDateTemplate,
  );
}
