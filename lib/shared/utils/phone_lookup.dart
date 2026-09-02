const _legacyTrPrefix = '+90';

/// F8-3 ile aynı geçiş penceresi mantığı (bkz. `functions/src/shared/phone-lookup.ts`
/// — `phoneLookupCandidates`, BİLEREK aynı davranış). `users/{uid}.phoneNumber`
/// F8-2 öncesi hep çıplak (prefiksiz) 10 haneli TR numarasıydı; migration
/// script'i bunları `+90` önekiyle E.164'e çevirir, ama migration çalışana
/// KADAR hâlâ eski çıplak kayıtlar olabilir — `phoneIndex` de o dönemde bu
/// çıplak haliyle yazılmış olabilir. Bir `+90` numarası için önce tam
/// E.164'ü, bulamazsa eski çıplak halini dener; TR dışı numaralarda tek
/// aday döner.
List<String> phoneLookupCandidates(String value) {
  if (!value.startsWith(_legacyTrPrefix)) return [value];
  final bareDigits = value.substring(_legacyTrPrefix.length);
  if (bareDigits.isEmpty) return [value];
  return [value, bareDigits];
}
