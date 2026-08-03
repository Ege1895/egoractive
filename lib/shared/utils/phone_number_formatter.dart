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
