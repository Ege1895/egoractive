const trMonthAbbreviations = {
  1: 'Oca',
  2: 'Şub',
  3: 'Mar',
  4: 'Nis',
  5: 'May',
  6: 'Haz',
  7: 'Tem',
  8: 'Ağu',
  9: 'Eyl',
  10: 'Eki',
  11: 'Kas',
  12: 'Ara',
};

/// `DateTime`'ı "18 Ağu 2026" biçiminde Türkçe kısa ay adıyla formatlar.
String formatTrDate(DateTime date) =>
    '${date.day} ${trMonthAbbreviations[date.month]} ${date.year}';
