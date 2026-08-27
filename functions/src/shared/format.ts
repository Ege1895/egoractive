const MONTH_NAMES_TR = [
  "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
  "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık",
];

export function formatDateTr(date: Date): string {
  return `${date.getDate()} ${MONTH_NAMES_TR[date.getMonth()]} ${date.getFullYear()}`;
}

export function formatMonthLabelTr(date: Date): string {
  return `${MONTH_NAMES_TR[date.getMonth()]} ${date.getFullYear()}`;
}

/** `weekEnd` aralığın hariç ucudur (son gün `weekEnd` - 1 gün). */
export function formatWeekRangeTr(weekStart: Date, weekEnd: Date): string {
  const lastDay = new Date(weekEnd.getTime() - 24 * 60 * 60 * 1000);
  return `${formatDateTr(weekStart)} – ${formatDateTr(lastDay)}`;
}
