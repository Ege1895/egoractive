/**
 * Uygulama tek bir ülkeye/saat dilimine özel değil — bir etkinlik/grup
 * dersinin "1 gün önce akşam 21:00" hatırlatması, salonun bulunduğu YERİN
 * yerel saatine göre hesaplanmalı (bkz. `notification-locale.ts`'teki
 * `resolveGymTimeZone`). Node'un `Intl` API'si dışında ek bir kütüphaneye
 * ihtiyaç duymadan bunu yapmak için standart "iki geçişli" teknik
 * kullanılıyor: önce yerel saat bileşenlerini UTC'ymiş gibi varsayıp bir
 * tahmini an üretilir, sonra o anın gerçekte `timeZone`'da hangi saate denk
 * geldiği ölçülüp fark kadar düzeltilir.
 */

/** `date` (bir UTC anı) `timeZone`'da hangi takvim gününe denk geliyor? */
export function localDateParts(date: Date, timeZone: string): { year: number; month: number; day: number } {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);
  const map = Object.fromEntries(parts.map((p) => [p.type, p.value]));
  return { year: Number(map.year), month: Number(map.month), day: Number(map.day) };
}

/**
 * `timeZone`'da `year`-`month`-`day` `hour`:`minute`'e denk gelen UTC anını
 * döner. DST geçiş anının tam içine denk gelen (yılda birkaç dakikalık)
 * kenar durumlarda birkaç dakikalık sapma olabilir — bir push bildirimi
 * için önemsiz.
 */
export function zonedTimeToUtc(year: number, month: number, day: number, hour: number, minute: number, timeZone: string): Date {
  const guessMs = Date.UTC(year, month - 1, day, hour, minute, 0);
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone,
    hourCycle: "h23",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
  }).formatToParts(new Date(guessMs));
  const map = Object.fromEntries(parts.map((p) => [p.type, p.value]));
  const asUtcIfLocalWereUtc = Date.UTC(
    Number(map.year),
    Number(map.month) - 1,
    Number(map.day),
    Number(map.hour),
    Number(map.minute),
    Number(map.second),
  );
  const offsetMs = asUtcIfLocalWereUtc - guessMs;
  return new Date(guessMs - offsetMs);
}

/**
 * F4-2/F4-3 hatırlatması — bir etkinlik/grup dersinin başlangıcının salon
 * saatiyle YEREL takvim gününden BİR GÜN ÖNCESİNİN saat 21:00'ine denk
 * gelen UTC anını döner.
 */
export function oneDayBeforeAt21Local(occurrenceStart: Date, timeZone: string): Date {
  const { year, month, day } = localDateParts(occurrenceStart, timeZone);
  const dayBefore = new Date(Date.UTC(year, month - 1, day));
  dayBefore.setUTCDate(dayBefore.getUTCDate() - 1);
  return zonedTimeToUtc(dayBefore.getUTCFullYear(), dayBefore.getUTCMonth() + 1, dayBefore.getUTCDate(), 21, 0, timeZone);
}

/** `date`'i `timeZone`'da "HH:mm" olarak formatlar (push bildirimindeki {time} yer tutucusu için). */
export function formatTimeInZone(date: Date, timeZone: string): string {
  return new Intl.DateTimeFormat("tr-TR", {
    timeZone,
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).format(date);
}

/** `date`'i `timeZone`'da, `locale`'e uygun şekilde "15 Eylül"/"September 15"
 * (ya da `includeYear` ile "15 Eylül 2026"/"September 15, 2026") olarak formatlar. */
export function formatDateInZone(date: Date, timeZone: string, locale: "tr" | "en", includeYear = false): string {
  return new Intl.DateTimeFormat(locale === "tr" ? "tr-TR" : "en-US", {
    timeZone,
    day: "numeric",
    month: "long",
    year: includeYear ? "numeric" : undefined,
  }).format(date);
}

/** F5-11 — rapor maili ay etiketi: "Ağustos 2026"/"August 2026". */
export function formatMonthInZone(date: Date, timeZone: string, locale: "tr" | "en"): string {
  return new Intl.DateTimeFormat(locale === "tr" ? "tr-TR" : "en-US", {
    timeZone,
    month: "long",
    year: "numeric",
  }).format(date);
}

/** `date`'in `timeZone`'daki gün adını ("Pazartesi"/"Monday") döner. */
export function formatWeekdayInZone(date: Date, timeZone: string, locale: "tr" | "en"): string {
  return new Intl.DateTimeFormat(locale === "tr" ? "tr-TR" : "en-US", {
    timeZone,
    weekday: "long",
  }).format(date);
}
