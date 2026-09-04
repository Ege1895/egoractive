/**
 * "Her ay tekrar et" işaretli giderlerin takip eden aylara kopyalanması için
 * saf (Firestore'suz) yardımcılar — `scheduled/recurring-expense-check.ts`
 * bunları kullanır, testler de bunları doğrular.
 *
 * Neden kopya doküman üretiliyor da sorgu anında "sanal" satır gösterilmiyor:
 * `expenses` koleksiyonunu client'ta Giderler paneli ve admin dashboard'ı,
 * sunucuda ise haftalık/aylık rapor + PDF export (`weekly-report-stats.ts`)
 * OKUYOR ve hepsi `date` aralığına göre topluyor. Sanal satır sadece Giderler
 * panelinde görünür, rapor/dashboard/e-posta bundan habersiz kalırdı — ekran
 * "Eylül: 20.000" derken aylık rapor "0" derdi. Gerçek doküman yazmak bu dört
 * tüketiciyi tek hamlede tutarlı tutuyor.
 */

export interface YearMonth {
  year: number;
  /** 1-indexli (Ocak = 1). */
  month: number;
}

/**
 * Geriye dönük en fazla kaç ay doldurulur. Fonksiyon her gün çalıştığı için
 * normalde tek bir ay eksik olur; bu tavan sadece uzun süre kapalı kalmış /
 * yeni deploy edilmiş bir ortamda tek seferde binlerce yazma yapılmasını
 * engeller. 24 ay, "geçen yıl aynı ay"a kadar geriye bakan bir kullanıcıyı
 * fazlasıyla kapsıyor.
 */
export const maxRecurringCatchUpMonths = 24;

/** `2026-09` — Firestore'da string olarak saklanır, leksikografik sıralaması takvim sırasıyla aynı. */
export function monthKey({ year, month }: YearMonth): string {
  return `${year}-${String(month).padStart(2, "0")}`;
}

export function parseMonthKey(key: string | undefined): YearMonth | undefined {
  if (!key) return undefined;
  const match = /^(\d{4})-(\d{2})$/.exec(key);
  if (!match) return undefined;
  const year = Number(match[1]);
  const month = Number(match[2]);
  if (month < 1 || month > 12) return undefined;
  return { year, month };
}

export function addMonths({ year, month }: YearMonth, delta: number): YearMonth {
  const zeroBased = year * 12 + (month - 1) + delta;
  return { year: Math.floor(zeroBased / 12), month: (zeroBased % 12) + 1 };
}

/** a < b ise negatif, eşitse 0, a > b ise pozitif. */
export function compareMonths(a: YearMonth, b: YearMonth): number {
  return a.year * 12 + a.month - (b.year * 12 + b.month);
}

/**
 * `month` ayının gün sayısı. `Date.UTC(year, month, 0)` bir sonraki ayın
 * 0. günü = bu ayın son günü (JS ay indeksi 0-indexli olduğu için kasıtlı
 * kaydırma; `monthly-schedule.ts`'teki `isLastDayOfMonth` ile aynı teknik).
 */
export function daysInMonth({ year, month }: YearMonth): number {
  return new Date(Date.UTC(year, month, 0)).getUTCDate();
}

/**
 * Şablonun ayın 31'ine düşen bir gideri Şubat'a kopyalanırken ayın son
 * gününe çekilir (31 Ocak -> 28/29 Şubat). Aksi halde tarih bir sonraki aya
 * taşar ve gider yanlış ayda görünürdü.
 */
export function clampDayToMonth(day: number, target: YearMonth): number {
  return Math.min(day, daysInMonth(target));
}

/**
 * Bir tekrarlı gider şablonunun hangi aylara kopyalanması gerektiğini döner
 * (kronolojik sırada, şablonun kendi ayı hariç — o zaten gerçek kayıt).
 *
 * Kapsam ŞABLONUN YILININ SONUNA kadar: Ağustos 2026'ya girilen bir kira,
 * Eylül'den Aralık 2026'ya kadar tüm aylara kopyalanır ve takvimde ileriye
 * dönük görünür. 2027 için admin gideri yeniden girer — böylece yıl başında
 * tutar/karar gözden geçirilmiş oluyor, eski tutar sessizce sonraki yıla
 * taşınmıyor (ürün kararı, kullanıcı isteği 2026-09-05).
 *
 * `materializedThrough`, şablon üzerinde tutulan "bu aya kadar üretildi"
 * imleci: kopya doküman SİLİNSE bile o ay yeniden üretilmez. Silinen bir ayı
 * diriltmemek bilinçli — kullanıcı bir ayın kirasını kaldırdıysa ertesi gün
 * geri gelmemeli.
 */
export function pendingRecurringMonths(params: {
  templateMonth: YearMonth;
  materializedThrough: string | undefined;
  currentMonth: YearMonth;
  maxMonths?: number;
}): YearMonth[] {
  const { templateMonth, currentMonth } = params;
  const maxMonths = params.maxMonths ?? maxRecurringCatchUpMonths;

  const marker = parseMonthKey(params.materializedThrough);
  const afterTemplate = addMonths(templateMonth, 1);
  let start = marker && compareMonths(marker, templateMonth) > 0 ? addMonths(marker, 1) : afterTemplate;

  // Tavanı aşan çok eski boşluklar bilinçli olarak atlanır: en yeni
  // `maxMonths` ay doldurulur, imleç de sonuna kadar ilerletilir.
  const oldestAllowed = addMonths(currentMonth, -(maxMonths - 1));
  if (compareMonths(start, oldestAllowed) < 0) start = oldestAllowed;

  // Yıl sonu sınırı: geçmiş boşluklar da, gelecek aylar da şablonun kendi
  // yılıyla sınırlı. Aralık'a girilen bir şablon hiç kopya üretmez (bir
  // sonraki ay zaten gelecek yıl).
  const end: YearMonth = { year: templateMonth.year, month: 12 };

  const months: YearMonth[] = [];
  for (let cursor = start; compareMonths(cursor, end) <= 0; cursor = addMonths(cursor, 1)) {
    months.push(cursor);
  }
  return months;
}
