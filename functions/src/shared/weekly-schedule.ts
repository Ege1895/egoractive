import { RemoteConfigTemplate } from "firebase-admin/remote-config";

const ISTANBUL_TIME_ZONE = "Europe/Istanbul";

const WEEKDAY_TO_ISO: Record<string, number> = {
  Mon: 1,
  Tue: 2,
  Wed: 3,
  Thu: 4,
  Fri: 5,
  Sat: 6,
  Sun: 7,
};

function readIntParam(template: RemoteConfigTemplate, key: string, fallback: number): number {
  const param = template.parameters[key];
  const raw = param?.defaultValue && "value" in param.defaultValue ? param.defaultValue.value : undefined;
  const parsed = raw === undefined ? NaN : Number.parseInt(raw, 10);
  return Number.isFinite(parsed) ? parsed : fallback;
}

/** İstanbul yerel saatinde ISO hafta günü (1=Pazartesi..7=Pazar) ve saat (0-23). */
export function istanbulDayAndHour(date: Date): { isoDayOfWeek: number; hour: number } {
  const parts = new Intl.DateTimeFormat("en-US", {
    timeZone: ISTANBUL_TIME_ZONE,
    weekday: "short",
    hour: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);

  const weekday = parts.find((p) => p.type === "weekday")?.value ?? "Mon";
  const hour = Number.parseInt(parts.find((p) => p.type === "hour")?.value ?? "0", 10);
  return { isoDayOfWeek: WEEKDAY_TO_ISO[weekday] ?? 1, hour };
}

/**
 * F5-2 — `cfg_weekly_report_day_of_week`/`cfg_weekly_report_hour` RC
 * değerlerine göre, "şimdi" haftalık rapor gönderme zamanı mı kontrol eder.
 * Fonksiyonlar saatte bir çalışıp bu kontrolü yapar — böylece RC değeri
 * değiştiğinde yeniden deploy gerekmez (LiveOps ilkesi).
 */
export function isWeeklyReportDue(template: RemoteConfigTemplate, now: Date): boolean {
  const dayOfWeek = readIntParam(template, "cfg_weekly_report_day_of_week", 1);
  const hour = readIntParam(template, "cfg_weekly_report_hour", 6);
  const current = istanbulDayAndHour(now);
  return current.isoDayOfWeek === dayOfWeek && current.hour === hour;
}

/** "İlgili hafta": önceki tam hafta pazartesi 00:00 (dahil) - şimdiki pazartesi 00:00 (hariç), İstanbul takvim günü. */
export function previousWeekRange(now: Date): { weekStart: Date; weekEnd: Date } {
  const { isoDayOfWeek } = istanbulDayAndHour(now);
  const istanbulNow = new Date(now.toLocaleString("en-US", { timeZone: ISTANBUL_TIME_ZONE }));
  const startOfToday = new Date(istanbulNow.getFullYear(), istanbulNow.getMonth(), istanbulNow.getDate());
  const weekEnd = new Date(startOfToday.getTime() - (isoDayOfWeek - 1) * 24 * 60 * 60 * 1000);
  const weekStart = new Date(weekEnd.getTime() - 7 * 24 * 60 * 60 * 1000);
  return { weekStart, weekEnd };
}
