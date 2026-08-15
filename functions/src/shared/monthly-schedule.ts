import { RemoteConfigTemplate } from "firebase-admin/remote-config";

const ISTANBUL_TIME_ZONE = "Europe/Istanbul";

/** İstanbul yerel takvim tarihi (yıl/ay/gün). */
export function istanbulYearMonthDay(date: Date): { year: number; month: number; day: number } {
  const parts = new Intl.DateTimeFormat("en-CA", {
    timeZone: ISTANBUL_TIME_ZONE,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).formatToParts(date);

  return {
    year: Number(parts.find((p) => p.type === "year")?.value),
    month: Number(parts.find((p) => p.type === "month")?.value),
    day: Number(parts.find((p) => p.type === "day")?.value),
  };
}

/**
 * F5-4 — 28/29/30/31 gün farkı olan ayları doğru hesaplar: `month` burada
 * 1-indexli (Ocak=1) olduğu için `Date.UTC(year, month, 0)` bir sonraki ayın
 * 0. günü, yani doğrudan `month`ün son gününü verir (JS Date ay indeksi
 * 0-indexli olduğundan bu kaydırma kasıtlı).
 */
export function isLastDayOfMonth(date: Date): boolean {
  const { year, month, day } = istanbulYearMonthDay(date);
  const daysInMonth = new Date(Date.UTC(year, month, 0)).getUTCDate();
  return day === daysInMonth;
}

function readIntParam(template: RemoteConfigTemplate, key: string, fallback: number): number {
  const param = template.parameters[key];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = raw === undefined ? NaN : Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

/**
 * F5-4 — `cfg_feedback_reminder_day_of_month` RC değerine göre "bugün
 * hatırlatma günü mü" kontrol eder. -1 = ayın son günü.
 */
export function isFeedbackReminderDue(template: RemoteConfigTemplate, now: Date): boolean {
  const dayOfMonth = readIntParam(template, "cfg_feedback_reminder_day_of_month", -1);
  if (dayOfMonth === -1) return isLastDayOfMonth(now);
  return istanbulYearMonthDay(now).day === dayOfMonth;
}

/** İlgili ayın İstanbul takvimine göre başlangıcı (dahil) - bitişi (hariç). */
export function currentMonthRange(now: Date): { monthStart: Date; monthEnd: Date } {
  const { year, month } = istanbulYearMonthDay(now);
  const monthStart = new Date(Date.UTC(year, month - 1, 1));
  const monthEnd = new Date(Date.UTC(year, month, 1));
  return { monthStart, monthEnd };
}
